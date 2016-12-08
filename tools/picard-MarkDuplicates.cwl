#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/picard:2.7.1--py27_0

baseCommand: [ picard, MarkDuplicates, OUTPUT=output.bam, METRICS_FILE=metrics.txt ]

inputs:
  input:
    type: File
    inputBinding:
      prefix: INPUT=
  remove_duplicates:
    type: boolean
    default: true
    inputBinding:
      prefix: REMOVE_DUPLICATES=
      separate: false

outputs:
  output:
    type: File
    outputBinding:
      glob: output.bam
  metrics:
    type: File
    outputBinding:
      glob: metrics.txt
