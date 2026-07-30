from pathlib import Path
import sys


def test_report_template_contains_license_link():
    repo_root = Path(__file__).resolve().parents[1]
    template_path = repo_root / "src" / "templates" / "report_template.html"

    content = template_path.read_text(encoding="utf-8")

    assert 'href="LICENSE"' in content


def test_setup_output_directory_copies_license_to_output(tmp_path):
    repo_root = Path(__file__).resolve().parents[1]
    sys.path.insert(0, str(repo_root / "src"))

    from utils.output_manager import setup_output_directory

    output_dir = tmp_path / "report"
    template_dir = repo_root / "src" / "templates"
    static_dir = repo_root / "webapp"

    setup_output_directory(output_dir, template_dir, static_dir)

    license_path = output_dir / "LICENSE"
    assert license_path.exists()
    assert "MIT License" in license_path.read_text(encoding="utf-8")
