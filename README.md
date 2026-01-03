# Scalable Spark ETL Pipeline for Analytics and Machine Learning

## Overview

This project implements a distributed data processing pipeline using Apache Spark and Hadoop HDFS to analyze competitive programming problems and solutions from the DeepMind CodeContests dataset. The system leverages Hive for data warehousing, performs complex joins and aggregations, and applies machine learning techniques to predict problem difficulty ratings.

## Tech Stack

- **Languages**: Python, SQL
- **Big Data**: Apache Spark (PySpark), Apache Hive, Hadoop HDFS
- **Storage**: Parquet, JSONL
- **Containerization**: Docker, Docker Compose
- **Machine Learning**: Spark MLlib (Decision Tree Regression)
- **Data Processing**: Spark RDD, DataFrame, and SQL APIs

## Architecture

The pipeline consists of a multi-container Docker environment:

- **Namenode**: HDFS namenode for metadata management
- **Datanode**: HDFS datanode for distributed data storage
- **Spark Boss**: Spark master node coordinating cluster operations
- **Spark Workers**: Two worker nodes for parallel processing (2 cores, 2GB memory each)
- **Jupyter Notebook**: Interactive development environment with JupyterLab

## Key Features

### Data Processing

- **Multi-API Support**: Implemented data filtering using Spark RDD, DataFrame, and SQL APIs
- **Hive Integration**: Created bucketed Hive tables for optimized GROUP BY operations
- **Query Optimization**: Leveraged bucketing to eliminate shuffle/exchange operations
- **Data Caching**: Applied strategic caching to improve query performance on filtered datasets

### Data Warehousing

- **Hive Tables**: Persistent storage for problems and solutions datasets
- **Temporary Views**: Created views for reference data (languages, sources, tags, test cases)
- **Bucketing Strategy**: Partitioned solutions data by language into 4 buckets for query optimization

### Analytics

- **Complex Joins**: Performed multi-table joins across problems, solutions, sources, and languages
- **Aggregations**: Computed statistics including counts, averages, and categorical groupings
- **Difficulty Classification**: Categorized problems into Easy/Medium/Hard based on difficulty scores

### Machine Learning

- **Feature Engineering**: Used VectorAssembler to combine difficulty, time_limit, and memory_limit_bytes features
- **Predictive Modeling**: Trained a Decision Tree Regressor (max depth 5) to predict Codeforces ratings
- **Model Evaluation**: Computed R² scores on test data to assess prediction accuracy
- **Missing Value Imputation**: Applied trained model to predict missing ratings for unlabeled problems

## Project Structure

```
.
├── docker-compose.yml          # Multi-container orchestration
├── p5-base.Dockerfile          # Base image with Hadoop, Spark, Python
├── namenode.Dockerfile         # HDFS namenode configuration
├── datanode.Dockerfile         # HDFS datanode configuration
├── boss.Dockerfile             # Spark master node
├── worker.Dockerfile           # Spark worker nodes
├── notebook.Dockerfile         # JupyterLab environment
├── build.sh                    # Build script for all Docker images
├── get_data.py                 # Dataset download and preprocessing script
├── requirements.txt            # Python dependencies
├── .gitignore                  # Git exclusions
└── nb/
    ├── p5.ipynb                # Main analysis notebook
    └── data/                   # Dataset directory (not included in repo)
```

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- Python 3.8+ with pip
- Minimum 8GB RAM available for Docker

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd spark-etl-analytics-pipeline
   ```

2. **Create Python virtual environment**

   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install dataset library**

   ```bash
   pip install datasets==3.3.2
   ```

4. **Create data directory**

   ```bash
   mkdir -p nb/data
   ```

5. **Download dataset**

   ```bash
   python get_data.py
   ```

   This downloads the DeepMind CodeContests dataset and generates:

   - `problems.jsonl`: Programming problem descriptions
   - `solutions.jsonl`: Solution submissions
   - `languages.csv`: Language ID mappings
   - `sources.csv`: Source platform mappings
   - `tags.csv`: Problem tags
   - `problem_tests.csv`: Test case information

6. **Build Docker images**

   ```bash
   chmod +x build.sh
   ./build.sh
   ```

   Or manually:

   ```bash
   docker build . -f p5-base.Dockerfile -t p5-base
   docker build . -f notebook.Dockerfile -t p5-nb
   docker build . -f namenode.Dockerfile -t p5-nn
   docker build . -f datanode.Dockerfile -t p5-dn
   docker build . -f boss.Dockerfile -t p5-boss
   docker build . -f worker.Dockerfile -t p5-worker
   ```

7. **Start the cluster**

   ```bash
   export PROJECT=p5
   docker compose up -d
   ```

8. **Access JupyterLab**

   - Open browser to `http://localhost:5000/lab`
   - Navigate to `p5.ipynb`
   - Run the initial cell to upload data to HDFS

9. **Stop the cluster**
   ```bash
   docker compose down
   ```

## Analysis Workflow

The notebook (`nb/p5.ipynb`) implements the following analysis pipeline:

1. **Data Loading**: Load JSONL files from HDFS into Spark DataFrames
2. **Filtering**: Apply complex filters using RDD, DataFrame, and SQL APIs
3. **Hive Tables**: Create optimized bucketed tables for efficient querying
4. **View Creation**: Generate temporary views for reference data
5. **Joins**: Perform inner joins across multiple tables
6. **Aggregations**: Compute counts, averages, and grouped statistics
7. **Caching**: Measure performance impact of DataFrame caching
8. **ML Pipeline**: Train and evaluate Decision Tree model for rating prediction

## Performance Optimizations

- **Bucketing**: Solutions table bucketed by language (4 buckets) eliminates shuffle in GROUP BY queries
- **Caching**: Strategic DataFrame caching reduces computation time by up to 80% on repeated queries
- **Memory Allocation**: Configured 1GB executor memory per Spark job
- **HDFS Replication**: Set replication factor to 1 for development environment

## Results

The pipeline successfully:

- Filtered 8,573 total problems with specific criteria
- Categorized difficulty into 409 Easy, 5,768 Medium, and 2,396 Hard problems
- Achieved measurable performance improvements through caching
- Trained a Decision Tree model with R² score indicating prediction accuracy
- Predicted missing Codeforces ratings for unlabeled problems

## Dataset Information

**Source**: DeepMind CodeContests Dataset (Hugging Face)

**Content**:

- 8,573 programming problems from multiple competitive programming platforms
- Solutions in Python 2, Python 3, C++, and Java
- Problem metadata including difficulty ratings, time limits, memory constraints
- Test cases with input/output specifications
- Source platforms: CodeChef, Codeforces, HackerEarth, Code Jam

## Notes

- Dataset files are excluded from version control (see `.gitignore`)
- The cluster requires approximately 7.5GB of memory allocation
- HDFS runs in single-node mode for development purposes
- Spark UI available at `http://localhost:4040` during job execution

## Academic Context

This project was completed as part of a distributed systems and big data analytics course, demonstrating practical skills in:

- Distributed data processing with Spark
- Data warehousing with Hive
- Query optimization techniques
- Machine learning pipeline development
- Container orchestration with Docker

