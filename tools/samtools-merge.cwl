#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: 'quay.io/biocontainers/samtools'
  SoftwareRequirement:
    packages:
    - package: samtools
      version: [ "1.5" ]

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
