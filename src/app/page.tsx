import { AuthGuard } from "@/components/auth-guard";

export default function Home() {
  return (
    <AuthGuard>
      <main className="flex min-h-screen flex-col items-center justify-center p-24">
        <h1 className="text-4xl font-bold text-brand-700">Octagonl App</h1>
        <p className="mt-4 text-neutral-500">You are signed in. Start building your app.</p>
      </main>
    </AuthGuard>
  );
}
