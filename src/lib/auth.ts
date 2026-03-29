import type { NextAuthOptions } from "next-auth";

/**
 * next-auth configuration for Octagonl SSO via Microsoft Entra External ID.
 *
 * Key rules:
 * - Uses Authorization Code + PKCE + client secret
 * - Maps `oid` claim (not `sub`) as stable user identity across all Octagonl apps
 * - Stores oid as `entraOid` in session
 */
export const authOptions: NextAuthOptions = {
  providers: [
    {
      id: "azure-ad",
      name: "Octagonl Account",
      type: "oidc",
      issuer: process.env.OIDC_ISSUER,
      clientId: process.env.OIDC_CLIENT_ID!,
      clientSecret: process.env.OIDC_CLIENT_SECRET!,
      authorization: { params: { scope: "openid profile email" } },
      profile(profile) {
        return {
          id: profile.oid ?? profile.sub,
          name: profile.name,
          email: profile.email ?? profile.preferred_username,
          entraOid: profile.oid,
        };
      },
    },
  ],
  callbacks: {
    async jwt({ token, account, profile }) {
      if (account && profile) {
        token.entraOid = (profile as Record<string, unknown>).oid as string;
        token.accessToken = account.access_token;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        (session.user as Record<string, unknown>).entraOid = token.entraOid;
        (session as Record<string, unknown>).accessToken = token.accessToken;
      }
      return session;
    },
  },
  session: { strategy: "jwt", maxAge: 8 * 60 * 60 },
  pages: { signIn: "/api/auth/signin" },
};
