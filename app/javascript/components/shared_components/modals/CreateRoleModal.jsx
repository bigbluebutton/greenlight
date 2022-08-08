import React from 'react';
import { Button } from 'react-bootstrap';
import CreateRoleForm from '../../admin/roles/forms/CreateRoleForm';
import Modal from './Modal';

export default function CreateRoleModal() {
  return (
    <Modal
      modalButton={<Button variant="brand" className="ms-auto">+ Create Role</Button>}
      title="Create New Role"
      body={<CreateRoleForm />}
    />
  );
}
