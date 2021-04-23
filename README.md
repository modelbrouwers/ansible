# Ansible

Ansible playbook(s) for deployment of the Modelbrouwers.nl domain.

Contains the setup for container-based deployment of:

* webshop (OpenCart)
* Django
* forum (phpBB3)

Including the various databases:

* MySQL
* PostgreSQL

All of this is frontend by an nginx reverse proxy with Let's Encrypt TLS certificates.

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
