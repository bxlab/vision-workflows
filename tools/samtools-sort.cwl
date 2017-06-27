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

baseCommand: ["samtools", "sort"]

arguments:
- prefix: "--threads"
  valueFrom: $(runtime.cores)
- prefix: "-T"
  valueFrom: $TMPDIR

inputs:
  input:
    type: File
    inputBinding:
      position: 1

outputs:
  output:
    type: stdout
