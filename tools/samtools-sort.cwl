#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/samtools'

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
