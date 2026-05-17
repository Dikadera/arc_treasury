/**
 * Copyright 2026 Circle Internet Group, Inc.  All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

import { EnvVarWarning } from "@/components/env-var-warning";
import { AuthButton } from "@/components/auth-button";
import { Hero } from "@/components/hero";
import { ThemeSwitcher } from "@/components/theme-switcher";
import { hasEnvVars } from "@/lib/utils";
import Link from "next/link";
import { Suspense } from "react";
// 1. Correct import paths for Supabase and cookies
import { createClient } from "@/lib/supabase/server";

async function TodoList() {
  const supabase = await createClient();
  const { data: todos } = await supabase.from('todos').select();

  return (
    <div className="w-full max-w-5xl p-5">
      <h2 className="font-bold text-2xl mb-4">Todos from Supabase:</h2>
      <ul className="list-disc pl-5">
        {todos?.map((todo) => (
          <li key={todo.id}>{todo.name}</li>
        ))}
        {(!todos || todos.length === 0) && <li>No todos found.</li>}
      </ul>
    </div>
  );
}

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center">
      <div className="flex-1 w-full flex flex-col gap-20 items-center">
        <nav className="w-full flex justify-center border-b border-b-foreground/10 h-16">
          <div className="w-full max-w-5xl flex justify-between items-center p-3 px-5 text-sm">
            <div className="flex gap-5 items-center font-semibold">
              <ThemeSwitcher />
              <Link href={"/"} className="flex items-center gap-2">
                <span className="bg-gradient-to-r from-blue-600 to-amber-600 bg-clip-text text-transparent font-bold text-xl">
                  Circle Fintech Starter
                </span>
              </Link>
            </div>
            {!hasEnvVars ? (
              <EnvVarWarning />
            ) : (
              <Suspense>
                <AuthButton />
              </Suspense>
            )}
          </div>
        </nav>
        <Hero />

        {/* 3. Display your fetched todos here wrapped in Suspense */}
        <Suspense fallback={<div className="p-5">Loading todos...</div>}>
          <TodoList />
        </Suspense>

      </div>
    </main>
  );
}
