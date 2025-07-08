#!/usr/bin/env python3
"""
Advanced Security Analysis for Azure Terraform Ollama Deployment
Author: Vinay Jain (https://github.com/vinex22)
Repository: https://github.com/vinex22/azure_terraform_olama

This script performs advanced security analysis on Terraform and YAML files
"""

import json
import re
import sys
import yaml
import os
from typing import Dict, List, Tuple

class SecurityAnalyzer:
    def __init__(self):
        self.issues = []
        self.warnings = []
        self.passed = []
        
    def add_issue(self, severity: str, message: str, file_path: str = "", line_number: int = 0):
        """Add a security issue"""
        issue = {
            'severity': severity,
            'message': message,
            'file': file_path,
            'line': line_number
        }
        
        if severity.upper() in ['CRITICAL', 'HIGH']:
            self.issues.append(issue)
        elif severity.upper() in ['MEDIUM', 'LOW']:
            self.warnings.append(issue)
        else:
            self.passed.append(issue)
    
    def analyze_terraform_file(self, file_path: str) -> None:
        """Analyze Terraform files for security issues"""
        if not os.path.exists(file_path):
            if file_path == 'main.tf':  # Only main.tf is critical
                self.add_issue('HIGH', f'Required Terraform file not found: {file_path}')
            return
            
        with open(file_path, 'r') as f:
            content = f.read()
            lines = content.split('\n')
        
        # Only analyze main.tf for security configurations, others are just variable/output definitions
        if file_path == 'main.tf':
            self._check_terraform_security_patterns(content, lines, file_path)
        else:
            # For other files, just check for obvious security issues
            self._check_terraform_basic_patterns(content, lines, file_path)
        
    def _check_terraform_basic_patterns(self, content: str, lines: List[str], file_path: str) -> None:
        """Check for basic security patterns in non-main Terraform files"""
        
        # Check for hardcoded secrets in variable files
        if 'variables.tf' in file_path or 'outputs.tf' in file_path:
            secret_patterns = ['password', 'secret', 'token', 'api_key']
            for pattern in secret_patterns:
                if re.search(f'{pattern}.*=.*"[^"]+"', content, re.IGNORECASE):
                    self.add_issue('HIGH', f'Potential hardcoded {pattern} in {file_path}')
    
    def _check_terraform_security_patterns(self, content: str, lines: List[str], file_path: str) -> None:
        """Check for specific security patterns in Terraform"""
        
        # Check SSH configuration
        if 'disable_password_authentication = true' in content:
            self.add_issue('PASS', 'Password authentication is disabled', file_path)
        else:
            self.add_issue('HIGH', 'Password authentication should be disabled', file_path)
        
        # Check SSH key strength
        if 'rsa_bits  = 4096' in content or 'rsa_bits = 4096' in content:
            self.add_issue('PASS', 'SSH key uses 4096-bit RSA', file_path)
        else:
            self.add_issue('MEDIUM', 'Consider using 4096-bit RSA keys for better security', file_path)
        
        # Check for overly permissive network rules
        nsg_patterns = re.findall(r'source_address_prefix\s*=\s*"([^"]*)"', content)
        for pattern in nsg_patterns:
            if pattern == '*' or pattern == '0.0.0.0/0':
                self.add_issue('MEDIUM', f'Overly permissive network rule allows access from any IP: {pattern}', file_path)
        
        # Check for Network Security Group
        if 'azurerm_network_security_group' in content:
            self.add_issue('PASS', 'Network Security Group is configured', file_path)
        else:
            self.add_issue('HIGH', 'Network Security Group is missing', file_path)
        
        # Check for encryption settings
        if 'disk_encryption_set_id' in content:
            self.add_issue('PASS', 'Disk encryption is configured', file_path)
        else:
            self.add_issue('MEDIUM', 'Consider enabling disk encryption for enhanced security', file_path)
        
        # Check for monitoring/logging
        if 'boot_diagnostics' in content:
            self.add_issue('PASS', 'Boot diagnostics is enabled', file_path)
        else:
            self.add_issue('LOW', 'Consider enabling boot diagnostics for troubleshooting', file_path)
        
        # Check for tags (good for governance)
        if re.search(r'tags\s*=\s*{', content):
            self.add_issue('PASS', 'Resource tagging is implemented', file_path)
        else:
            self.add_issue('LOW', 'Consider adding tags for better resource governance', file_path)
    
    def analyze_yaml_file(self, file_path: str) -> None:
        """Analyze YAML files for security issues"""
        if not os.path.exists(file_path):
            self.add_issue('MEDIUM', f'YAML file not found: {file_path}')
            return
            
        try:
            with open(file_path, 'r') as f:
                content = f.read()
                yaml_data = yaml.safe_load(f)
        except yaml.YAMLError as e:
            self.add_issue('HIGH', f'Invalid YAML syntax in {file_path}: {e}')
            return
        except Exception as e:
            self.add_issue('MEDIUM', f'Error reading {file_path}: {e}')
            return
        
        # Check for security patterns in YAML
        self._check_yaml_security_patterns(content, file_path)
    
    def _check_yaml_security_patterns(self, content: str, file_path: str) -> None:
        """Check for security patterns in YAML content"""
        
        # Check for hardcoded credentials
        credential_patterns = [
            r'password\s*:\s*\S+',
            r'secret\s*:\s*\S+',
            r'token\s*:\s*\S+',
            r'api_key\s*:\s*\S+'
        ]
        
        for pattern in credential_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                self.add_issue('HIGH', f'Potential hardcoded credential found in {file_path}')
                break
        else:
            self.add_issue('PASS', f'No hardcoded credentials detected in {file_path}')
        
        # Check for insecure downloads
        if re.search(r'http://[^\s]+', content):
            self.add_issue('MEDIUM', f'Unencrypted HTTP download detected in {file_path}')
        else:
            self.add_issue('PASS', f'No unencrypted HTTP downloads in {file_path}')
        
        # Check for dangerous shell operations
        if re.search(r'curl[^|]*\|[^|]*sh', content):
            self.add_issue('HIGH', f'Dangerous curl|sh pattern detected in {file_path}')
        
        # Check package update practices
        if 'package_update: true' in content:
            self.add_issue('PASS', f'Package updates are enabled in {file_path}')
        else:
            self.add_issue('LOW', f'Consider enabling package updates in {file_path}')
    
    def analyze_gitignore(self, file_path: str = '.gitignore') -> None:
        """Analyze .gitignore for security-sensitive patterns"""
        if not os.path.exists(file_path):
            self.add_issue('MEDIUM', '.gitignore file not found')
            return
        
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Check for important security exclusions
        required_patterns = [
            'ssh_keys',
            '*.tfstate',
            '*.tfvars',
            '*.pem',
            '*.key'
        ]
        
        missing_patterns = []
        for pattern in required_patterns:
            if pattern not in content:
                missing_patterns.append(pattern)
        
        if missing_patterns:
            self.add_issue('MEDIUM', f'.gitignore missing security patterns: {", ".join(missing_patterns)}')
        else:
            self.add_issue('PASS', '.gitignore properly excludes sensitive files')
    
    def check_file_permissions(self) -> None:
        """Check for files with insecure permissions"""
        sensitive_files = ['*.key', '*.pem', 'terraform.tfvars']
        
        for pattern in sensitive_files:
            # In a real implementation, we'd check actual file permissions
            # For now, we'll check if the pattern exists in .gitignore
            pass
    
    def generate_report(self) -> Dict:
        """Generate security analysis report"""
        return {
            'summary': {
                'critical_issues': len([i for i in self.issues if i['severity'].upper() == 'CRITICAL']),
                'high_issues': len([i for i in self.issues if i['severity'].upper() == 'HIGH']),
                'medium_issues': len([i for i in self.warnings if i['severity'].upper() == 'MEDIUM']),
                'low_issues': len([i for i in self.warnings if i['severity'].upper() == 'LOW']),
                'passed_checks': len(self.passed)
            },
            'issues': self.issues,
            'warnings': self.warnings,
            'passed': self.passed
        }
    
    def print_report(self) -> None:
        """Print formatted security report"""
        report = self.generate_report()
        
        print("🔍 Advanced Security Analysis Report")
        print("=" * 40)
        print()
        
        # Summary
        summary = report['summary']
        print(f"📊 Summary:")
        print(f"  Critical Issues: {summary['critical_issues']}")
        print(f"  High Issues: {summary['high_issues']}")
        print(f"  Medium Issues: {summary['medium_issues']}")
        print(f"  Low Issues: {summary['low_issues']}")
        print(f"  Passed Checks: {summary['passed_checks']}")
        print()
        
        # Issues
        if report['issues']:
            print("❌ Security Issues:")
            for issue in report['issues']:
                print(f"  [{issue['severity']}] {issue['message']}")
                if issue['file']:
                    print(f"     File: {issue['file']}")
            print()
        
        # Warnings
        if report['warnings']:
            print("⚠️  Security Warnings:")
            for warning in report['warnings']:
                print(f"  [{warning['severity']}] {warning['message']}")
                if warning['file']:
                    print(f"     File: {warning['file']}")
            print()
        
        # Passed checks
        if report['passed']:
            print("✅ Passed Security Checks:")
            for passed in report['passed'][:5]:  # Show first 5
                print(f"  {passed['message']}")
            if len(report['passed']) > 5:
                print(f"  ... and {len(report['passed']) - 5} more")
            print()
        
        # Recommendations
        print("💡 Security Recommendations:")
        if summary['critical_issues'] > 0 or summary['high_issues'] > 0:
            print("  • Address all critical and high severity issues before deployment")
        if summary['medium_issues'] > 0:
            print("  • Review and consider fixing medium severity issues")
        print("  • Run 'docker run --rm -v $(pwd):/src aquasec/tfsec:latest /src' for detailed Terraform analysis")
        print("  • Run './security-test.sh' for comprehensive security testing")
        print("  • Consider implementing Azure Security Center for runtime monitoring")

def main():
    """Main function"""
    analyzer = SecurityAnalyzer()
    
    print("🔒 Starting Advanced Security Analysis...")
    print()
    
    # Analyze Terraform files
    terraform_files = ['main.tf', 'variables.tf', 'outputs.tf']
    for tf_file in terraform_files:
        analyzer.analyze_terraform_file(tf_file)
    
    # Analyze YAML files
    yaml_files = ['cloud-init.yaml']
    for yaml_file in yaml_files:
        analyzer.analyze_yaml_file(yaml_file)
    
    # Analyze .gitignore
    analyzer.analyze_gitignore()
    
    # Generate and print report
    analyzer.print_report()
    
    # Exit with appropriate code
    report = analyzer.generate_report()
    if report['summary']['critical_issues'] > 0:
        sys.exit(2)
    elif report['summary']['high_issues'] > 0:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()