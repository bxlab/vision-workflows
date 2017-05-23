#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - $import: types.cwl

inputs:
  replicates:
    doc: List of replicates
    type:
      type: array
      items:
        type: record
        fields:
          treatment:
            doc: Reads for treatment
            type: "types.cwl#ReadPair"
          control:
            doc: Reads for control
            type: "types.cwl#ReadPair"
  idxbase:
    doc: Base filename of bwa index to map against
    type: File
  blacklist:
    doc: Blacklist regions to remove
    type: File

outputs:
  pooled_narrowpeak_file:
    doc: Peaks for each replicate
    type: File
    outputSource: name_outputs/out_pooled_narrowpeak_file
  replicate_narrowpeak_files:
    doc: Peaks from pooling replicates
    type: File[]
    outputSource: name_outputs/out_replicate_narrowpeak_files
  idr_narrowpeak_file:
    doc: Peaks surviving IDR using pooled peaks as oracle
    type: File
    outputSource: name_outputs/out_idr_narrowpeak_file

steps:
  align_treatment:
    doc: Align treatment reads for all replictes
    run: chipseq_tf_align.cwl
    in:
      reads: 
        source: replicates
        valueFrom: $(self.treatment)
      idxbase: idxbase
      blacklist: blacklist
    out: [processed_reads]
    scatter: [ reads ]
  align_control:
    doc: Align control reads for all replicates
    run: chipseq_tf_align.cwl
    in:
      reads: 
        source: replicates
        valueFrom: $(self.control)
      idxbase: idxbase
      blacklist: blacklist
    out: [processed_reads]
    scatter: [ reads ]
  replicate_call_peaks:
    doc: Call peaks for replicates independently
    run: tools/macs-callpeak.cwl
    in:
      treatment: align_treatment/processed_reads
      control: align_control/processed_reads
    out: [narrowpeak_file]
    scatter: [ treatment, control ]
    scatterMethod: dotproduct
  pooled_replicates_treatment:
    doc: Pool treatment reads for all replicates
    run: tools/samtools-merge.cwl
    in:
      input: 
        source: align_treatment/processed_reads
    out: [ output ]
  pooled_replicates_control:
    doc: Pool control reads for all replicates
    run: tools/samtools-merge.cwl
    in:
      input: 
        source: align_control/processed_reads
    out: [ output ]
  pooled_call_peaks:
    doc: Call peaks on pooled reads
    run: tools/macs-callpeak.cwl
    in:
      treatment: pooled_replicates_treatment/output
      control: pooled_replicates_control/output
    out: [narrowpeak_file, treatment_pileup_bdg]
  idr:
    doc: Run IDR analysis using pooled peaks as "oracle" peak list
    run: tools/idr.cwl
    in:
        samples: replicate_call_peaks/narrowpeak_file
        peak-list: pooled_call_peaks/narrowpeak_file
    out:
        [output]
  name_outputs:
    doc: Rename outputs to avoid conflicts
    in:
      replicate_narrowpeak_files: replicate_call_peaks/narrowpeak_file
      pooled_narrowpeak_file: pooled_call_peaks/narrowpeak_file
      idr_narrowpeak_file: idr/output
    out: [ out_replicate_narrowpeak_files, out_pooled_narrowpeak_file, out_idr_narrowpeak_file ]
    run:
      class: ExpressionTool
      inputs: 
        replicate_narrowpeak_files: File[]
        pooled_narrowpeak_file: File
        idr_narrowpeak_file: File
      outputs:
        out_replicate_narrowpeak_files: File[]
        out_pooled_narrowpeak_file: File
        out_idr_narrowpeak_file: File
      expression: |
        ${
        var outputs = { 
            out_replicate_narrowpeak_files = inputs.replicate_narrowpeak_files,
            out_pooled_narrowpeak_file = inputs.pooled_narrowpeak_file,
            out_idr_narrowpeak_file = inputs.idr_narrowpeak_file
        }
        outputs.out_replicate_narrowpeak_files.forEach( function( e, i ) {
          e.basename = "Rep_" + i.toString() + ".narrowPeak";
        });
        outputs.out_pooled_narrowpeak_file.basename = "Pooled.narrowPeak";
        outputs.out_idr_narrowpeak_file.basename = "Pooled_IDR.narrowPeak";
        return outputs;
        }
