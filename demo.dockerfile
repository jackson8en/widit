# Example how to use your own custom dockerfile

# Use any base image; the creator script will layer the wsl things on top
FROM ubuntu:22.04

RUN touch /root/demo.dockerfile-was-here
