#!/bin/bash
set -e

MIX_ENV=test mix clean
MIX_ENV=test mix test
