/**
 * App.tsx – Mala DAO dApp (wagmi v2) with Debug panel
 * ----------------------------------------------------
 * Shows Chain, Token, Governor, Wallet and live MGT balance.
 */

import { useState } from 'react';
import {
  WagmiProvider,
  createConfig,
  http,
  useAccount,
  useConnect,
  useDisconnect,
  useReadContract,
} from 'wagmi';
import { sepolia } from 'viem/chains';
import { metaMask } from '@wagmi/connectors';
import { formatUnits } from 'viem';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import governorAbi from './abi/GovernorDAO.json';
import tokenJson from './abi/Token.json';
const tokenAbi = tokenJson.abi as const;

import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';

/* -------------------------------------------------------------------------- */
/*  Config                                                                     */
/* -------------------------------------------------------------------------- */

const CHAIN = sepolia;

const wagmiConfig = createConfig({
  chains: [CHAIN],
  transports: { [CHAIN.id]: http() },
  connectors: [metaMask()],
});

const queryClient = new QueryClient();

const TOKEN_ADDRESS = (import.meta as any).env.VITE_TOKEN_ADDRESS as `0x${string}`;
const GOVERNOR_ADDRESS = (import.meta as any).env.VITE_GOVERNOR_ADDRESS as `0x${string}`;
const CHAIN_ID = (import.meta as any).env.VITE_CHAIN_ID ?? '—';

/* -------------------------------------------------------------------------- */
/*  Debug panel                                                                */
/* -------------------------------------------------------------------------- */
function DebugPanel() {
  const { address } = useAccount();
  return (
    <div className="rounded-lg bg-gray-100 p-4 text-xs font-mono text-gray-600 space-y-1">
      <p><span className="font-semibold">Chain ID:</span> {CHAIN_ID}</p>
      <p><span className="font-semibold">Token:</span> {TOKEN_ADDRESS}</p>
      <p><span className="font-semibold">Governor:</span> {GOVERNOR_ADDRESS}</p>
      <p><span className="font-semibold">Wallet:</span> {address ?? '— (disconnected)'} </p>
    </div>
  );
}

/* -------------------------------------------------------------------------- */
/*  Wallet connect                                                             */
/* -------------------------------------------------------------------------- */
function ConnectWallet() {
  const { address, isConnected } = useAccount();
  const { connect, connectors, status } = useConnect();
  const { disconnect } = useDisconnect();

  if (!isConnected) {
    return (
      <Button onClick={() => connect({ connector: connectors[0] })} disabled={status === 'connecting'} className="w-full">
        {status === 'connecting' ? 'Connecting…' : 'Connect MetaMask'}
      </Button>
    );
  }

  return (
    <div className="space-y-2">
      <p className="truncate text-sm font-mono">{address}</p>
      <Button variant="secondary" onClick={() => disconnect()} className="w-full">Disconnect</Button>
    </div>
  );
}

/* -------------------------------------------------------------------------- */
/*  Balance gate                                                               */
/* -------------------------------------------------------------------------- */
function BalanceGate({ children }: { children: (balance: bigint) => JSX.Element }) {
  const { address } = useAccount();

  const { data, error, status } = useReadContract({
    address: TOKEN_ADDRESS,
    abi: tokenAbi as any,
    functionName: 'balanceOf',
    args: address ? [address as `0x${string}`] : undefined,
    chainId: CHAIN.id,
    watch: true,
    query: { enabled: Boolean(address) },
  });

  const balance = (data || 0n) as bigint;
  console.log('balance query →', { data, error, status });
  return (
    <div className="space-y-4">
      <p className="text-sm text-muted-foreground">
        MGT balance: <span className="font-semibold">{formatUnits(balance, 18)}</span>
      </p>
      {balance > 0n ? children(balance) : <p className="text-xs text-red-500">You need MGT tokens to propose or vote.</p>}
    </div>
  );
}

/* -------------------------------------------------------------------------- */
/*  App                                                                        */
/* -------------------------------------------------------------------------- */
export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <WagmiProvider config={wagmiConfig}>
        <main className="flex min-h-screen flex-col items-center justify-center bg-gray-50 p-4">
          <Card className="w-full max-w-lg space-y-6 shadow-xl p-6">
            <ConnectWallet />
            <DebugPanel />
            <BalanceGate>{() => <></>}</BalanceGate>
          </Card>
        </main>
      </WagmiProvider>
    </QueryClientProvider>
  );
}
