import React from 'react';
import { toast } from 'react-hot-toast';
import CustomToast from '../components/shared_components/utilities/CustomToast';

function createSuccessToast(localeKey) {
  toast.custom((t) => <CustomToast variant="success" localeKey={localeKey} dismiss={() => toast.dismiss(t.id)} />);
}

function createErrorToast(localeKey) {
  toast.custom((t) => <CustomToast variant="error" localeKey={localeKey} dismiss={() => toast.dismiss(t.id)} />);
}

function createWarningToast(localeKey) {
  toast.custom((t) => <CustomToast variant="warning" localeKey={localeKey} dismiss={() => toast.dismiss(t.id)} />);
}

export default {
  createSuccessToast,
  createErrorToast,
  createWarningToast,
};
