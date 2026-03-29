import NextAuth from "next-auth";

declare module "next-auth" {
  interface Session {
    user: { name?: string | null; email?: string | null; image?: string | null; entraOid?: string; };
    accessToken?: string;
  }
  interface Profile { oid?: string; preferred_username?: string; }
}

declare module "next-auth/jwt" {
  interface JWT { entraOid?: string; accessToken?: string; }
}
