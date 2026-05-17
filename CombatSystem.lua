-- ============================================================
--  CombatSystem.lua
--  Production-quality combat system for Roblox
--  Author: Your Name
--  Description: Handles health, damage, critical hits, and death
-- ============================================================

local CombatSystem = {}
CombatSystem.__index = CombatSystem

-- ── CONSTANTS ──────────────────────────────────────────────
local DEFAULT_MAX_HEALTH = 100
local DEFAULT_CRIT_CHANCE = 0.15   -- 15% chance
local DEFAULT_CRIT_MULTIPLIER = 2.0

-- ── CONSTRUCTOR ────────────────────────────────────────────
-- Creates a new character with combat stats
-- @param name (string) - The character's name
-- @param maxHealth (number) - Maximum health points
-- @return CombatSystem instance
function CombatSystem.new(name, maxHealth)
    local self = setmetatable({}, CombatSystem)

    self.name         = name or "Unknown"
    self.maxHealth    = maxHealth or DEFAULT_MAX_HEALTH
    self.currentHealth = self.maxHealth
    self.isAlive      = true
    self.critChance   = DEFAULT_CRIT_CHANCE
    self.critMultiplier = DEFAULT_CRIT_MULTIPLIER

    return self
end

-- ── GET HEALTH ─────────────────────────────────────────────
-- Returns current health of the character
-- @return number
function CombatSystem:getHealth()
    return self.currentHealth
end

-- ── IS DEAD ────────────────────────────────────────────────
-- Returns true if the character is dead
-- @return boolean
function CombatSystem:isDead()
    return not self.isAlive
end

-- ── TAKE DAMAGE ────────────────────────────────────────────
-- Applies damage to the character, handles crit and death
-- @param amount (number) - Base damage amount
-- @param isCritical (boolean) - Optional: force a critical hit
-- @return table { damageDone, wasCritical, died }
function CombatSystem:takeDamage(amount, isCritical)
    -- Guard: already dead
    if not self.isAlive then
        return { damageDone = 0, wasCritical = false, died = false }
    end

    -- Guard: damage must be positive
    if type(amount) ~= "number" or amount <= 0 then
        return { damageDone = 0, wasCritical = false, died = false }
    end

    -- Check for critical hit
    local wasCritical = isCritical or (math.random() < self.critChance)
    local finalDamage = amount

    if wasCritical then
        finalDamage = amount * self.critMultiplier
    end

    -- Apply damage (never go below 0)
    self.currentHealth = math.max(0, self.currentHealth - finalDamage)

    -- Check death
    local died = false
    if self.currentHealth <= 0 then
        self.isAlive = false
        died = true
        self:onDeath()
    end

    return {
        damageDone  = finalDamage,
        wasCritical = wasCritical,
        died        = died
    }
end

-- ── HEAL ───────────────────────────────────────────────────
-- Restores health, cannot exceed maxHealth
-- @param amount (number) - Amount to heal
-- @return number - Actual amount healed
function CombatSystem:heal(amount)
    -- Guard: cannot heal a dead character
    if not self.isAlive then return 0 end

    -- Guard: heal amount must be positive
    if type(amount) ~= "number" or amount <= 0 then return 0 end

    local before = self.currentHealth
    self.currentHealth = math.min(self.maxHealth, self.currentHealth + amount)

    return self.currentHealth - before  -- actual healed amount
end

-- ── ON DEATH ───────────────────────────────────────────────
-- Called automatically when character dies
-- Override this in your game for custom death behavior
function CombatSystem:onDeath()
    print(string.format("[CombatSystem] %s has died!", self.name))
end

-- ── REVIVE ─────────────────────────────────────────────────
-- Brings a dead character back to life
-- @param healthPercent (number) - 0.0 to 1.0, default 0.5
function CombatSystem:revive(healthPercent)
    healthPercent = healthPercent or 0.5
    healthPercent = math.clamp(healthPercent, 0.01, 1.0)

    self.isAlive = true
    self.currentHealth = math.floor(self.maxHealth * healthPercent)

    print(string.format("[CombatSystem] %s revived with %d HP!", self.name, self.currentHealth))
end

-- ── GET STATUS ─────────────────────────────────────────────
-- Returns a summary of the character's current state
-- @return table
function CombatSystem:getStatus()
    return {
        name          = self.name,
        currentHealth = self.currentHealth,
        maxHealth     = self.maxHealth,
        isAlive       = self.isAlive,
        healthPercent = self.currentHealth / self.maxHealth
    }
end

return CombatSystem
