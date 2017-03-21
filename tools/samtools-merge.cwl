#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/samtools'

baseCommand: ["samtools", "merge", "merged.bam" ]

arguments:
- prefix: --threads
  valueFrom: $(runtime.cores)

inputs:
  input:
    type: File[]
    inputBinding:
      position: 2

outputs:
  output:
    type: File
    outputBinding:
        glob: merged.bam
