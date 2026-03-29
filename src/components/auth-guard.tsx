"use client";

import { useSession, signIn } from "next-auth/react";

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { status } = useSession();

  if (status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-neutral-500">Loading...</p>
      </div>
    );
  }

  if (status === "unauthenticated") {
    signIn("azure-ad");
    return null;
  }

  return <>{children}</>;
}
