#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/samtools'

baseCommand: ["samtools", "view", "-b"]

arguments:
- prefix: "-t"
  valueFrom: $(runtime.cores)

inputs:
  input:
    type: File
    inputBinding:
      position: 1

outputs:
  output:
    type: stdout
