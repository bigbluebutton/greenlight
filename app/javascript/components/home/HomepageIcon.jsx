import React from 'react';
import { Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function HomepageIcon({ title, description, icon }) {
  return (
    <Stack className="text-center my-3 my-md-5 homepage-icon d-block mx-auto">
      <div className="mb-3">
        {/* Icons are created by Pixel perfect on Flaticons.com */}
        <img src={icon} alt="" />
      </div>
      <h4> {title} </h4>
      <span> {description} </span>
    </Stack>
  );
}

HomepageIcon.propTypes = {
  title: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  icon: PropTypes.string.isRequired,
};
