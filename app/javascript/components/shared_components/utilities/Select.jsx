import React, {
  useCallback, useEffect, useMemo, useReducer,
} from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'react-bootstrap';

export const SelectContext = React.createContext(null);

export const ACTIONS = {
  SELECT: 'SELECT',
};

const reducer = (state, action) => {
  switch (action.type) {
    case ACTIONS.SELECT:
      return { title: action.msg.title, value: action.msg.value };
    default:
      return state;
  }
};

export default function Select({
  children, id, variant, isValid, defaultOpt, onChange, onBlur,
}) {
  const [selected, dispatch] = useReducer(reducer, defaultOpt);

  const current = useMemo(() => ({ selected, dispatch }), [selected.title, selected.value]);
  const handleBlur = useCallback(() => { onBlur(selected.value); }, [onBlur]);

  useEffect(() => { onChange(selected.value); }, [onChange, selected.value]);

  return (
    <SelectContext.Provider value={current}>
      <Dropdown id={id} className="select d-grid mt-1 border-0 p-0">
        <Dropdown.Toggle
          onBlur={handleBlur}
          className="text-start text-black border-1 form-control"
          variant={isValid ? variant : 'delete'}
        >
          {selected.title}
        </Dropdown.Toggle>

        <Dropdown.Menu className="container-fluid">
          {children}
        </Dropdown.Menu>
      </Dropdown>
    </SelectContext.Provider>
  );
}

Select.defaultProps = {
  variant: 'brand-outline',
  id: undefined,
  onChange: () => { },
  onBlur: () => { },
  isValid: true,
};

Select.propTypes = {
  id: PropTypes.string,
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  variant: PropTypes.string,
  onChange: PropTypes.func,
  onBlur: PropTypes.func,
  isValid: PropTypes.bool,
  defaultOpt: PropTypes.shape({
    title: PropTypes.string.isRequired,
    value: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.bool]),
  }).isRequired,
};
