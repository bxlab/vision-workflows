#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
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
  narrowpeak_file:
    type: File[]
    outputSource: call_peaks/narrowpeak_file

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
  call_peaks:
    run: tools/macs-callpeak.cwl
    in:
      treatment: align_treatment/processed_reads
      control: align_control/processed_reads
    out: [narrowpeak_file]
    scatter: [ treatment, control ]
    scatterMethod: dotproduct
