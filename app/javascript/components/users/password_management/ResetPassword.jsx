import React, { useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import useVerifyToken from '../../../hooks/mutations/users/useVerifyToken';
import FormLogo from '../../shared_components/forms/FormLogo';
import ResetPwdForm from './forms/ResetPwdForm';
import Spinner from '../../shared_components/utilities/Spinner';

export default function ResetPassword() {
  const { token } = useParams();
  const verifyToken = useVerifyToken();

  useEffect(() => {
    verifyToken.mutate({ user: { token } });
  }, []);

  if (verifyToken.isLoading) return <Spinner />;

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
