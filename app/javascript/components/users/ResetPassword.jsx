import React from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import FormLogo from '../forms/FormLogo';
import ResetPwdForm from '../forms/ResetPwdForm';

export default function ResetPassword() {
  const { token } = useParams();

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
          <ResetPwdForm token={token} />
        </Card>
      </div>
    </div>
  );
}
