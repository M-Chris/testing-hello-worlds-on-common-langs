# Benchmarking API Frameworks Using 16 Workers

This project began as a curiosity to test and compare the performance of popular API frameworks under a high-concurrency environment using **16 workers**. The results were **surprising**, providing valuable insights into how different frameworks handle heavy loads. The goal is to help developers choose the right framework based on the specific needs of their projects, balancing **performance** and **development ease**.

We used `wrk`, a popular load-testing tool, to simulate real-world performance scenarios and measure key metrics such as **requests per second**, **latency**, and **data transfer rates**. The frameworks tested include **Express.js**, **FastAPI**, **Go**, and **Rust (Actix-Web)**.

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Usage](#usage)
3. [Benchmark Results](#benchmark-results)
4. [Guidelines for Choosing a Framework](#guidelines-for-choosing-a-framework)

---

## Getting Started

## Prerequisites

Before running the benchmarks, ensure the following dependencies are installed#

## wrk The load-testing tool used for benchmarking#
```bash
brew install wrk
```
## Bash The script is written for Bash (version 4.x or higher)#
```bash
brew install bash
```
## Language-specific dependencies
## Node.js (for Express.js)
```bash
brew install node
```
## Python (for FastAPI)
```bash
brew install python3
pip install fastapi uvicorn
```
## Go (for Go API)
```bash
brew install go
```
## Rust (for Actix-Web)
```bash
brew install rust
```

## Project Setup

1.	Clone the repository
2.	Make the benchmarking script executable
```bash
chmod +x bench_all.sh
```

## Usage

## Running Benchmarks

To run benchmarks for all frameworks with 16 workers#
```bash
./bench_all.sh 16
```

This will

	Start the server for each framework (Express.js, FastAPI, Go, Rust)
	Run the benchmark using wrk (12 threads, 400 connections for 30 seconds)
	Save the benchmark results in the benchmark_results/ directory
	Display the results in a summary table

## Benchmark Results

Below are the results of the benchmarks run on a Mac M-Chip series using 16 workers for each framework

```
====== Benchmark Results ======
App             Requests/sec         Latency         Transfer/sec        
-------------------------------------------------------------
rust            156505.27            2.52ms          19.85MB             
express         94806.04             4.21ms          23.51MB             
go              68834.87             5.71ms          8.80MB              
fastapi         43812.78             11.05ms         6.27MB              
=============================================================

```

## Guidelines for Choosing a Framework

When choosing a framework, developers will need to balance **performance** and **development experience** based on their project’s needs. Below is a comparison of how the frameworks performed in the benchmarks, along with considerations to help you make an informed choice.

### 1. Rust (Actix-Web)
- **Best for**: High-performance APIs, low-latency systems, and applications requiring heavy concurrency.
- **Requests/sec**: 156,505.27
- **Latency**: 2.52ms
- **Considerations**: Rust provides the best performance among the tested frameworks, with the highest requests per second and the lowest latency. However, it comes with a steeper learning curve. It’s ideal for performance-critical applications where control over system resources is essential.

### 2. Express.js (Node.js)
- **Best for**: I/O-heavy applications, rapid development, and projects that benefit from a large ecosystem.
- **Requests/sec**: 94,806.04
- **Latency**: 4.21ms
- **Considerations**: Express.js offers simplicity and speed in development, making it great for quick prototyping. It also has a vast ecosystem of libraries. While its performance is lower than Rust, it’s still excellent for most web API applications.

### 3. Go (Golang)
- **Best for**: High-concurrency APIs, simple and fast development with a minimalist approach.
- **Requests/sec**: 68,834.87
- **Latency**: 5.71ms
- **Considerations**: Go provides a good balance between performance and ease of development. It’s a solid choice for microservices and systems requiring efficient concurrency handling. Though its performance is somewhat lower than Rust and Express, it’s still a robust option.

### 4. FastAPI (Python)
- **Best for**: Python-based projects, ease of development, and automatic documentation.
- **Requests/sec**: 43,812.78
- **Latency**: 11.05ms
- **Considerations**: FastAPI excels in developer productivity, especially for APIs requiring validation and serialization. However, its performance is the lowest in this benchmark, which could be a limitation for applications with high-performance needs.


