# ML-Driven Utility-Based Hybrid VLC-RF Routing for Congestion-Aware UAV-Assisted VANETs

A machine learning-driven hybrid VLC-RF routing framework for congestion-aware UAV-assisted Vehicular Ad Hoc Networks (VANETs). The framework combines Random Forest-based link reliability prediction with utility-based routing to improve communication reliability, throughput, and latency under dynamic vehicular environments.

---

## Overview

Vehicular Ad Hoc Networks (VANETs) are characterized by high mobility, rapidly changing topologies, and varying traffic conditions, making reliable communication a significant challenge. Conventional routing protocols such as AODV primarily focus on shortest-path routing without considering factors like congestion, channel quality, or link reliability.

This project presents an intelligent routing framework that integrates Machine Learning, Hybrid Visible Light Communication (VLC), Radio Frequency (RF) communication, and UAV-assisted networking to select reliable communication paths while minimizing congestion and transmission delay.

---

## Key Features

- Hybrid VLC-RF communication model
- UAV-assisted vehicular networking
- Random Forest-based link reliability prediction
- Utility-driven adaptive routing
- Congestion-aware next-hop selection
- Multiple congestion scenario evaluation
- Performance comparison with AODV
- MATLAB-generated simulation dataset

---

## System Workflow

The proposed routing framework follows these stages:

1. Generate vehicular communication dataset.
2. Extract physical and network-layer features.
3. Predict reliable communication links using a Random Forest classifier.
4. Filter unreliable links.
5. Compute utility scores for reliable links.
6. Select the optimal next hop based on maximum utility.
7. Evaluate routing performance under different congestion scenarios.

---

## Project Structure

```
ML-Driven-Hybrid-VLC-RF-Routing/
│
├── datasets/
│   ├── congestion_dataset_v4.csv
│   ├── congestion_dataset_v5.csv
│   └── congestion_dataset_v6.csv
│
├── notebooks/
│   └── Congestion_Aware_Routing_3Scenarios.ipynb
│
├── images/
│   ├── system_model.png
│   ├── topology.png
│   ├── correlation_matrix.png
│   ├── pdr.png
│   ├── throughput.png
│   ├── delay.png
│   └── congestion_index.png
│  
├── MC_simulation_dataset_generation.mat
│  
├── Manuscript.pdf
│
└── README.md
```

---

## Dataset

The project contains simulation datasets generated under multiple congestion conditions.

Each communication sample includes features such as:

- Source Node
- Destination Node
- Node Type
- Distance
- Relative Speed
- Traffic Density
- Queue Length
- Signal-to-Noise Ratio (SNR)
- Link Type (VLC/RF)
- Blockage Probability
- Link Reliability Label

---

## Machine Learning Model

### Algorithm

- Random Forest Classifier

### Training Configuration

- 20,000 communication samples
- 80:20 Train-Test Split
- Stratified Sampling
- 350 Decision Trees
- Maximum Tree Depth: 8
- Balanced Class Weights

### Input Features

- Distance
- Relative Speed
- Traffic Density
- Queue Length
- SNR
- Link Type
- Blockage Probability

### Output

Binary Link Classification

- Reliable
- Unreliable

---

## Utility-Based Routing

After reliable links are identified, routing decisions are made using a multi-objective utility function that considers:

- Channel Capacity
- Effective Delay
- Congestion Index
- Outage Probability
- Blockage Probability
- Distance Progress

The next hop is selected from all reliable neighboring nodes based on the maximum utility value.

---

## Simulation Parameters

| Parameter | Value |
|-----------|-------|
| Number of Vehicles | 100 |
| Number of UAVs | 4 |
| Road Length | 500 m |
| RF Frequency | 5.9 GHz |
| Communication Bandwidth | 10 MHz |
| Packet Size | 12000 bits |
| Maximum Vehicle Speed | 140 km/h |
| Reliable VLC Range | 110 m |

---

## Results

The proposed framework was evaluated against the conventional AODV routing protocol under high, medium, and low congestion scenarios.

### Performance Metrics

- Packet Delivery Ratio (PDR)
- Throughput
- End-to-End Delay
- Congestion Index (CI)
- Classification Accuracy
- Precision
- F1 Score

### Performance Highlights

- Higher Packet Delivery Ratio
- Increased Throughput
- Reduced End-to-End Delay
- Lower Congestion Index
- Robust Link Reliability Prediction

---

## Repository Contents

- Simulation datasets
- Jupyter notebooks
- System architecture
- Performance visualizations
- Routing implementation
- Experimental results
- Documentation

---

## Installation

Clone the repository

```bash
git clone https://github.com/<your-username>/ML-Driven-Hybrid-VLC-RF-Routing.git
```

Move into the project directory

```bash
cd ML-Driven-Hybrid-VLC-RF-Routing
```

Launch Jupyter Notebook

```bash
jupyter notebook
```

Open

```
notebooks/Congestion_Aware_Routing_3Scenarios.ipynb
```

---

## Technologies Used

- Python
- Jupyter Notebook
- MATLAB
- NumPy
- Pandas
- Scikit-learn
- Matplotlib

---

## Applications

- Intelligent Transportation Systems (ITS)
- Smart Highways
- Autonomous Vehicles
- UAV-Assisted Communication
- Congestion-Aware Routing
- Vehicular Communication Networks

---

## Future Work

Future enhancements include:

- Graph Neural Networks (GNNs) for topology-aware routing
- Bayesian optimization of utility weights
- Evolutionary optimization techniques
- SUMO-based mobility integration
- Multi-lane urban traffic scenarios
- Deep Reinforcement Learning-based routing

---

## License

This project is licensed under the MIT License.

---

## Acknowledgements

This project was developed as part of undergraduate research in Machine Learning, Intelligent Transportation Systems, and Vehicular Ad Hoc Networks.
