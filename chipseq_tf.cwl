#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement

inputs:
  reads:
    doc: Reads to map, either single or paired
    type:
      type: array
      items:
          type: record
          fields:
            in1: File
            in2: File?
  idxbase:
    doc: Base filename of bwa index to map against
    type: File

outputs:
  processed_reads:
    type: File[]
    outputSource: filter/output

steps:
  align:
    run: ./tools/bwa-mem.cwl
    in:
      reads: reads
      idxbase: idxbase
    out: [output]
    scatter: [ reads ]
    scatterMethod: dotproduct
  to_bam:
    run: ./tools/samtools-samtobam.cwl
    in:
      input: align/output
    out: [output]
    scatter: [ input ]
  sort:
    run: ./tools/samtools-sort.cwl
    in:
      input: to_bam/output
    out: [output]
    scatter: [ input ]
  mark_duplicates:
    run: ./tools/picard-MarkDuplicates.cwl
    in:
      input: sort/output
    out: [output]
    scatter: [ input ]
  filter:
    run: ./tools/samtools-view.cwl
    in:
      input: mark_duplicates/output
      filter_none_set:
        valueFrom: "4"
    scatter: [ input ]
    out: [output]
