import React from 'react';
import { Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import CreateRoleForm from '../../admin/roles/forms/CreateRoleForm';
import Modal from './Modal';

export default function CreateRoleModal() {
  const { t } = useTranslation();

  return (
    <Modal
      modalButton={<Button variant="brand" className="ms-auto">{ t('admin.roles.create_role') }</Button>}
      title={t('admin.roles.create_new_role')}
      body={<CreateRoleForm />}
    />
  );
}
