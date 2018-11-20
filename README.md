# Ansible

Ansible playbook(s) for deployment of the Modelbrouwers.nl domain.

Contains the setup for OpenCart, phpBB3, MySQL, PostgreSQL, Apache,
nginx and Django.


## Usage

```bash
ansible-playbook -i environments/production/hosts full-deploy.yml
```
