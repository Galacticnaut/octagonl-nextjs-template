/**
 * Platform API client for Octagonl services.
 */
const API_BASE_URL =
  process.env.NEXT_PUBLIC_PLATFORM_API_BASE_URL ||
  process.env.PLATFORM_API_BASE_URL ||
  "http://localhost:8080"\;

interface RequestOptions { accessToken: string; requestId?: string; }

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = "ApiError";
  }
}

async function apiRequest<T>(path: string, options: RequestOptions & RequestInit): Promise<T> {
  const { accessToken, requestId, ...fetchOptions } = options;
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    Authorization: `Bearer ${accessToken}`,
    ...(requestId && { "X-Request-Id": requestId }),
  };
  const res = await fetch(`${API_BASE_URL}${path}`, {
    ...fetchOptions,
    headers: { ...headers, ...(fetchOptions.headers as Record<string, string>) },
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new ApiError(res.status, (body as Record<string, string>).error || res.statusText);
  }
  return res.json() as Promise<T>;
}

export interface User { id: string; email: string; displayName?: string; createdAt: string; }
export interface Tenant { id: string; name: string; slug: string; role: string; createdAt: string; }
export interface Membership { id: string; tenantId: string; tenantName: string; tenantSlug: string; role: string; createdAt: string; }

export const platformApi = {
  async getMe(accessToken: string): Promise<User> {
    return apiRequest<User>("/v1/me", { accessToken, method: "GET" });
  },
  async getMemberships(accessToken: string): Promise<Membership[]> {
    return apiRequest<Membership[]>("/v1/me/memberships", { accessToken, method: "GET" });
  },
  async createTenant(accessToken: string, data: { name: string; slug: string }): Promise<Tenant> {
    return apiRequest<Tenant>("/v1/tenants", { accessToken, method: "POST", body: JSON.stringify(data) });
  },
  async getTenant(accessToken: string, tenantId: string): Promise<Tenant> {
    return apiRequest<Tenant>(`/v1/tenants/${encodeURIComponent(tenantId)}`, { accessToken, method: "GET" });
  },
};
