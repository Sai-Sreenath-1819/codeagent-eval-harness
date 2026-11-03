import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--run-docker", action="store_true", default=False, help="run tests marked `docker`"
    )


def pytest_collection_modifyitems(config, items):
    if config.getoption("--run-docker"):
        return
    skip = pytest.mark.skip(reason="needs --run-docker")
    for item in items:
        if "docker" in item.keywords:
            item.add_marker(skip)
