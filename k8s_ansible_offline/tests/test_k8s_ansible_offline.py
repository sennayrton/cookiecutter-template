"""Test module for k8s_ansible_offline."""

from k8s_ansible_offline import __author__, __email__, __version__


def test_project_info():
    """Test __author__ value."""
    assert __author__ == "Sergio"
    assert __email__ == "picazo63@gmail.com"
    assert __version__ == "0.0.0"
