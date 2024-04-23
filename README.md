# A2S Institute Docker Images

Our stacks provide GPU-enabled Jupyter Notebook in Docker containers, which can also run on Kubernetes. The images are based on [Jupyter docker-stacks jupyter/pytorch-notebook](https://github.com/jupyter/docker-stacks/tree/main/images/pytorch-notebook). All images are published on our [ghcr.io](https://github.com/orgs/a2s-institute/packages) and [quay.io](https://quay.io/user/a2s-institute/).

The stacks contain several machine learning packages such as TensorFlow, PyTorch, scikit-learn, and other machine learning tools. All images also include VSCode and xfce4 desktop environment.

## Docker stack structure
* [gpu-base-notebook](https://github.com/a2s-institute/docker-stacks/tree/master/base-gpu-notebook): contains Jupyter related libraries and also includes different cuda and pytorch versions. It also has VSCode and xfce4 desktop environment.
  * [ml-notebook](https://github.com/a2s-institute/docker-stacks/tree/master/ml-notebook): depends on `gpu-base-notebook` and includes several machine learning libaries such as TensorfLow, Keras, scipy, opencv, etc.
    * [nlp-notebook](https://github.com/a2s-institute/docker-stacks/tree/master/nlp-notebook): depends on `ml-notebook` and includes NLP libraries such as spaCy, NLTK, llama-cpp-python and wikipedia-api.

## Avilable versions
* `gpu-base-notebook:cuda11-pytorch-2.2.2`
* `gpu-base-notebook:cuda12-pytorch-2.2.2`
* `ml-notebook:cuda11-pytorch-2.2.2`
* `ml-notebook:cuda12-pytorch-2.2.2`
* `nlp-notebook:cuda11-pytorch-2.2.2`
* `nlp-notebook:cuda12-pytorch-2.2.2`

<details>
<summary><font color=blue> Older images</font></summary>

- `ghcr.io/a2s-institute/docker-stacks/gpu-notebook:cuda11.3.1-ubuntu22.04` (no vscode and xfce desktop)
- `ghcr.io/a2s-institute/docker-stacks/gpu-notebook:cuda11.8.0-ubuntu22.04` (no vscode and xfce desktop)
- `ghcr.io/a2s-institute/docker-stacks/gpu-notebook:cuda12.1.0-ubuntu22.04` (no vscode and xfce desktop)
- `ghcr.io/a2s-institute/docker-stacks/gpu-notebook:cuda12.1.0-ubuntu22.04` (no vscode and xfce desktop)

</details>

## Building and running A2S images locally

The base image  contains several packages for deep learning projects with NVidia GPU support.

* Build notebook image with gpu support
  ```
  # cuda11 and pytorch 2.2.2
  bash build_and_publish.sh --registry ghcr.io --publish "" \
      --image gpu-base-notebook --tag cuda11-pytorch-2.2.2

  # cuda12 and pytorch 2.2.2
  bash build_and_publish.sh --registry ghcr.io --publish "" \
      --image gpu-base-notebook --tag cuda12-pytorch-2.2.2
  ```

* Run the image locally
  ```
  # with GPU
  docker run --gpus all --name ml-notebook -it --rm -d -p 8888:8888 \
         quay.io/ml-notebook:cuda12-pytorch-2.2.2

  # without GPU
  docker run --name ml-notebook -it --rm -d -p 8888:8888 \
         quay.io/ml-notebook:cuda12-pytorch-2.2.2
  ```

* Check Jupyter Notebook token via log and open the link
  ```
  docker logs --follow ml-notebook

  ``` 

## Monitoring

You can monitor the GPU usage using nvtop

<img src="figures/nvtop.png" alt="nvtop gpu monitoring" width="640">

