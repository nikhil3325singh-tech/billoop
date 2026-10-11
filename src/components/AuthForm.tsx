import { Link, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { toast } from "sonner";
import { loginUser, signUpUser, useSession } from "@/lib/auth";
import { BrandMark, COMPANY } from "@/components/Marketing";
import { Loader2 } from "lucide-react";

export function AuthForm({ mode }: { mode: "login" | "signup" }) {
  const { session } = useSession();
  const navigate = useNavigate();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (session) {
      navigate({ to: "/dashboard", replace: true });
    }
  }, [session, navigate]);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanEmail = email.trim();
    const cleanName = name.trim();

    if (!cleanEmail || !password) {
      toast.error("Please fill in all required fields.");
      return;
    }

    if (mode === "signup" && !cleanName) {
      toast.error("Please enter your full name.");
      return;
    }

    if (password.length < 6) {
      toast.error("Password must be at least 6 characters.");
      return;
    }

    setBusy(true);

    try {
      if (mode === "signup") {
        const res = await signUpUser({ email: cleanEmail, password, fullName: cleanName });
        if (res.ok) {
          toast.success("Account created successfully!");
          navigate({ to: "/dashboard", replace: true });
        } else {
          toast.error(res.error || "Sign up failed");
        }
      } else {
        const res = await loginUser({ email: cleanEmail, password });
        if (res.ok) {
          toast.success("Logged in successfully!");
          navigate({ to: "/dashboard", replace: true });
        } else {
          toast.error(res.error || "Invalid login credentials");
        }
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Authentication error occurred";
      toast.error(msg);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="min-h-screen grid lg:grid-cols-2 relative">
      {/* Brand Visual Column */}
      <div className="hidden lg:flex flex-col justify-between bg-primary text-primary-foreground p-12">
        <div className="[&_*]:!text-primary-foreground">
          <BrandMark />
        </div>
        <div>
          <h2 className="font-display text-3xl font-bold leading-tight">
            Quotations and GST billing,
            <br />
            engineered for electrical contractors.
          </h2>
          <p className="opacity-80 mt-3 text-sm max-w-sm">
            Inventory, costing, branded templates and instant PDF / Word document exports in one place.
          </p>
        </div>
        <div className="text-xs opacity-70">
          © {new Date().getFullYear()} {COMPANY}. All rights reserved.
        </div>
      </div>

      {/* Auth Form Column */}
      <div className="flex items-center justify-center p-6 bg-background">
        <div className="w-full max-w-sm">
          <div className="lg:hidden mb-8">
            <BrandMark />
          </div>

          <h1 className="text-2xl font-semibold tracking-tight text-foreground">
            {mode === "login" ? "Welcome back" : "Create your account"}
          </h1>
          <p className="text-sm text-muted-foreground mt-1.5">
            {mode === "login"
              ? "Log in to manage quotations, inventory, and invoices."
              : "Start drafting compliant quotations and GST invoices in minutes."}
          </p>

          <form onSubmit={submit} className="mt-6 space-y-4">
            {mode === "signup" && (
              <label className="block">
                <span className="label-cap">Full Name</span>
                <input
                  required
                  type="text"
                  autoComplete="name"
                  placeholder="e.g. Rahul Sharma"
                  className="field mt-1 w-full"
                  value={name}
                  disabled={busy}
                  onChange={(e) => setName(e.target.value)}
                />
              </label>
            )}

            <label className="block">
              <span className="label-cap">Email Address</span>
              <input
                required
                type="email"
                autoComplete="email"
                placeholder="name@company.com"
                className="field mt-1 w-full"
                value={email}
                disabled={busy}
                onChange={(e) => setEmail(e.target.value)}
              />
            </label>

            <label className="block">
              <span className="label-cap">Password</span>
              <input
                required
                minLength={6}
                type="password"
                autoComplete={mode === "login" ? "current-password" : "new-password"}
                placeholder="Minimum 6 characters"
                className="field mt-1 w-full"
                value={password}
                disabled={busy}
                onChange={(e) => setPassword(e.target.value)}
              />
            </label>

            <button
              type="submit"
              disabled={busy}
              className="btn-primary w-full !py-2.5 mt-2 flex items-center justify-center gap-2"
            >
              {busy ? (
                <>
                  <Loader2 className="size-4 animate-spin" />
                  <span>{mode === "login" ? "Logging in…" : "Creating account…"}</span>
                </>
              ) : mode === "login" ? (
                "Log in"
              ) : (
                "Create account"
              )}
            </button>
          </form>

          <p className="text-sm text-muted-foreground mt-6 text-center">
            {mode === "login" ? (
              <>
                Don&apos;t have an account?{" "}
                <Link to="/signup" className="text-primary font-semibold hover:underline">
                  Sign up
                </Link>
              </>
            ) : (
              <>
                Already have an account?{" "}
                <Link to="/login" className="text-primary font-semibold hover:underline">
                  Log in
                </Link>
              </>
            )}
          </p>

          <p className="text-center mt-6">
            <Link to="/" className="text-xs text-muted-foreground hover:text-primary transition-colors">
              ← Back to home
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
