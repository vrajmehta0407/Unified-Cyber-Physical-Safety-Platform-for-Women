/**
 * Form validation helpers for the CyberShield dashboard.
 */

export function required(value, fieldName = 'Field') {
  if (!value || (typeof value === 'string' && !value.trim())) {
    return `${fieldName} is required`;
  }
  return null;
}

export function isEmail(value) {
  if (!value) return null;
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(value) ? null : 'Invalid email address';
}

export function isPhone(value) {
  if (!value) return null;
  const re = /^[6-9]\d{9}$/;
  return re.test(value) ? null : 'Invalid Indian mobile number';
}

export function minLength(value, min, fieldName = 'Field') {
  if (!value) return null;
  return value.length < min ? `${fieldName} must be at least ${min} characters` : null;
}

export function maxLength(value, max, fieldName = 'Field') {
  if (!value) return null;
  return value.length > max ? `${fieldName} must be at most ${max} characters` : null;
}

export function validateForm(rules) {
  const errors = {};
  for (const [field, checks] of Object.entries(rules)) {
    for (const check of checks) {
      const error = check();
      if (error) {
        errors[field] = error;
        break;
      }
    }
  }
  return Object.keys(errors).length ? errors : null;
}
