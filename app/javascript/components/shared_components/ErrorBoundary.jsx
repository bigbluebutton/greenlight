import React from 'react';
import PropTypes from 'prop-types';

export default class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { error: null, errorInfo: null };
  }

  componentDidCatch(error, errorInfo) {
    // Catch errors in any components below in the tree and re-render with error message
    this.setState({
      error,
      errorInfo,
    });
  }

  render() {
    const { error, errorInfo } = this.state;
    const { fallback: Fallback, children } = this.props;

    if (errorInfo) {
      // Rendering the fallback UI while providing the error object and info.
      return <Fallback error={error} errorInfo={errorInfo} />;
    }
    // In normal cases, render the subtree.
    return children;
  }
}

ErrorBoundary.defaultProps = {
  fallback: () => null,
};

ErrorBoundary.propTypes = {
  children: PropTypes.node.isRequired,
  fallback: PropTypes.func,
};
