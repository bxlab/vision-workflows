#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  replicates:
    type:
      type: array
      items:
        type: record
        fields:
          treatment:
            doc: Reads for treatment
            type:
              &array-of-pairs
              # FIXME: Why is name needed here but not above?? 
              #        See http://www.commonwl.org/v1.0/SchemaSalad.html#SaladRecordSchema
              #        and https://github.com/common-workflow-language/schema_salad/blob/master/schema_salad/schema.py#L411
              name: array-of-pairs
              type: record
              fields:
                in1: File
                in2: File?
          control:
            doc: Reads for control
            type:
              <<: *array-of-pairs
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
      reads: replicates/treatment
      idxbase: idxbase
      blacklist: blacklist
    out: [processed_reads]
    scatter: [ reads ]
  align_control:
    run: chipseq_tf_align.cwl
    in:
      reads: replicates/control
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
