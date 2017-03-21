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
    type: File
    outputSource: pooled_call_peaks/narrowpeak_file
  replicate_narrowpeak_files:
    type: File[]
    outputSource: pooled_call_peaks/narrowpeak_file
  # idr_peaks:
  #   type: File
  #   outputSource: idr/output

steps:
  align_treatment:
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
    run: tools/macs-callpeak.cwl
    in:
      treatment: align_treatment/processed_reads
      control: align_control/processed_reads
    out: [narrowpeak_file]
    scatter: [ treatment, control ]
    scatterMethod: dotproduct
  pooled_replicates_treatment:
    run: tools/samtools-merge.cwl
    in:
      input: 
        source: align_treatment/processed_reads
    out: [ output ]
  pooled_replicates_control:
    run: tools/samtools-merge.cwl
    in:
      input: 
        source: align_control/processed_reads
    out: [ output ]
  pooled_call_peaks:
    run: tools/macs-callpeak.cwl
    in:
      treatment: pooled_replicates_treatment/output
      control: pooled_replicates_control/output
    out: [narrowpeak_file]
  # idr:
  #   run: tools/idr.cwl
  #   in:
  #       samples: replicate_call_peaks/narrowpeak_file
  #       peak-list: pooled_call_peaks/narrowpeak_file
  #   out:
  #       [output]
