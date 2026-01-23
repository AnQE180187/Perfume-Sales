// Auth utility functions for role checking

/**
 * Check if user has admin role
 */
export function isAdmin(role?: string | null): boolean {
  if (!role) return false;
  return role.toUpperCase() === 'ADMIN';
}

/**
 * Check if user has staff role
 */
export function isStaff(role?: string | null): boolean {
  if (!role) return false;
  return role.toUpperCase() === 'STAFF';
}

/**
 * Check if user has admin or staff role
 */
export function isAdminOrStaff(role?: string | null): boolean {
  if (!role) return false;
  const upperRole = role.toUpperCase();
  return upperRole === 'ADMIN' || upperRole === 'STAFF';
}

/**
 * Check if user has any of the specified roles
 */
export function hasRole(userRole: string | null | undefined, allowedRoles: string[]): boolean {
  if (!userRole) return false;
  const upperUserRole = userRole.toUpperCase();
  return allowedRoles.some(role => role.toUpperCase() === upperUserRole);
}

/**
 * Check if user has any role in the roles array
 */
export function hasAnyRole(roles: string[] | null | undefined, allowedRoles: string[]): boolean {
  if (!roles || roles.length === 0) return false;
  return roles.some(role => hasRole(role, allowedRoles));
}
