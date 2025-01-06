import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mintEnergyPortal(portalType: string, description: string, capacity: number, stability: number, connectedUniverses: string[], creator: string) {
  const tokenId = ++lastTokenId;
  if (stability < 0 || stability > 100) {
    throw new Error('Invalid stability score');
  }
  tokenMetadata.set(tokenId, {
    creator,
    portalType,
    description,
    capacity,
    stability,
    connectedUniverses,
    creationTime: Date.now()
  });
  tokenOwners.set(tokenId, creator);
  return tokenId;
}

function transferEnergyPortal(tokenId: number, sender: string, recipient: string) {
  if (tokenOwners.get(tokenId) !== sender) {
    throw new Error('Not authorized');
  }
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Energy Portal NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new energy portal NFT', () => {
    const id = mintEnergyPortal('Quantum Bridge', 'Stable quantum tunnel between universes', 1000000, 95, ['Universe-A', 'Universe-B'], 'scientist1');
    expect(id).toBe(1);
    const metadata = tokenMetadata.get(id);
    expect(metadata.portalType).toBe('Quantum Bridge');
    expect(metadata.stability).toBe(95);
    expect(tokenOwners.get(id)).toBe('scientist1');
  });
  
  it('should transfer energy portal NFT ownership', () => {
    const id = mintEnergyPortal('Wormhole Gateway', 'High-capacity wormhole for bulk energy transfer', 5000000, 80, ['Universe-X', 'Universe-Y', 'Universe-Z'], 'scientist2');
    expect(transferEnergyPortal(id, 'scientist2', 'researcher1')).toBe(true);
    expect(tokenOwners.get(id)).toBe('researcher1');
  });
  
  it('should not allow minting with invalid stability score', () => {
    expect(() => mintEnergyPortal('Invalid Portal', 'This should fail', 100000, 101, ['Universe-Error'], 'scientist3')).toThrow('Invalid stability score');
  });
  
  it('should not allow unauthorized transfers', () => {
    const id = mintEnergyPortal('Cosmic String Tunnel', 'Experimental portal using cosmic strings', 10000000, 70, ['Universe-M', 'Universe-N'], 'scientist4');
    expect(() => transferEnergyPortal(id, 'unauthorized_user', 'researcher2')).toThrow('Not authorized');
  });
});

