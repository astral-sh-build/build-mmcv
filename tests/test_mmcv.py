import importlib
from importlib.metadata import version

import pytest
import torch


@pytest.fixture(scope="module")
def device() -> torch.device:
    assert torch.cuda.is_available(), "The tests must run on a CUDA GPU"
    device = torch.device("cuda")
    return device


def test_published_cuda_wheel(device: torch.device) -> None:
    assert version("mmcv") == "2.2.0+cu.12.8.torch.2.10"
    assert torch.__version__ == "2.10.0+cu128"
    assert torch.version.cuda == "12.8"
    assert torch.cuda.get_device_name(device)


@pytest.mark.parametrize("module_name", ["mmcv", "mmcv.ops", "mmcv._ext"])
def test_native_module(device: torch.device, module_name: str) -> None:
    assert importlib.import_module(module_name) is not None


def test_cuda_nms(device: torch.device) -> None:
    from mmcv.ops import nms

    boxes = torch.tensor(
        [[0.0, 0.0, 4.0, 4.0], [0.5, 0.5, 4.5, 4.5], [8.0, 8.0, 10.0, 10.0]],
        device=device,
    )
    scores = torch.tensor([0.9, 0.8, 0.7], device=device)
    _, indices = nms(boxes, scores, 0.5)
    torch.testing.assert_close(indices, torch.tensor([0, 2], device=device))


def test_cuda_roi_align_backward(device: torch.device) -> None:
    from mmcv.ops import roi_align

    features = torch.arange(16, dtype=torch.float32, device=device).reshape(1, 1, 4, 4)
    features.requires_grad_()
    rois = torch.tensor([[0, 0, 0, 3, 3]], dtype=torch.float32, device=device)
    result = roi_align(features, rois, (2, 2), 1.0, 0, "avg", True)
    assert result.shape == (1, 1, 2, 2)
    assert torch.isfinite(result).all()
    result.sum().backward()
    assert features.grad is not None
    assert torch.isfinite(features.grad).all()
