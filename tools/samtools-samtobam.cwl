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
