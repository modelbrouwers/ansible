# Ansible

Ansible playbook(s) for deployment of the Modelbrouwers.nl domain.

Contains the setup for OpenCart, phpBB3, MySQL, PostgreSQL, Apache,
nginx and Django.

## Requirements

```bash
pip install -r requirements.txt
```

You need ``root`` access to the server and access with the application user
``modelbrouw`` over SSH via public key.

## Usage

```bash
ansible-playbook -i environments/production/hosts full-deploy.yml
```

**Available playbooks**:

* `backups.yml`: configures the backups
* `django.yml`: updates the Django part of the site
* `app.yml`: django part + webshop and forum
* `full-deploy.yml`: `app.yml` + server provisioning
