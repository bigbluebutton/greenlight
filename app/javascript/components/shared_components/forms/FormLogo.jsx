import React from 'react';
import Image from 'react-bootstrap/Image';
import { Link } from 'react-router-dom';

export default function FormLogo() {
  return (
    <div className="text-center">
      <Link to="/">
        <Image src="https://blindsidenetworks.com/wp-content/uploads/2021/04/cropped-bn_logo-02.png" width="150px" className="pb-4" />
      </Link>
    </div>
  );
}
