import React, { useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import useVerifyToken from '../../../hooks/mutations/users/useVerifyToken';
import ResetPwdForm from './forms/ResetPwdForm';
import Spinner from '../../shared_components/utilities/Spinner';
import Logo from '../../shared_components/Logo';

export default function ResetPassword() {
  const { token } = useParams();
  const verifyTokenAPI = useVerifyToken(token);

  useEffect(() => {
    verifyTokenAPI.mutate();
  }, []);

  if (verifyTokenAPI.isIdle || verifyTokenAPI.isLoading) return <Spinner />;

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <ResetPwdForm token={token} />
      </Card>
    </div>
  );
}
