-- ============================================================
--  CombatSystem.test.lua
--  Unit Tests for CombatSystem
--  Framework: Busted (https://lunarmodules.github.io/busted/)
--  Run with: busted CombatSystem.test.lua
-- ============================================================

local CombatSystem = require("CombatSystem")

-- ── TEST SUITE ─────────────────────────────────────────────
describe("CombatSystem", function()

    -- A fresh character before each test
    local player

    before_each(function()
        player = CombatSystem.new("Hero", 100)
    end)

    -- ── CREATION TESTS ───────────────────────────────────
    describe("new()", function()

        it("creates a character with full health", function()
            assert.are.equal(100, player:getHealth())
        end)

        it("creates a character that is alive", function()
            assert.is_false(player:isDead())
        end)

        it("uses default health if none provided", function()
            local default = CombatSystem.new("Default")
            assert.are.equal(100, default:getHealth())
        end)

    end)

    -- ── TAKE DAMAGE TESTS ─────────────────────────────────
    describe("takeDamage()", function()

        it("reduces health by the correct amount", function()
            player:takeDamage(30)
            assert.are.equal(70, player:getHealth())
        end)

        it("does not reduce health below 0", function()
            player:takeDamage(999)
            assert.are.equal(0, player:getHealth())
        end)

        it("kills the character when health reaches 0", function()
            player:takeDamage(100)
            assert.is_true(player:isDead())
        end)

        it("doubles damage on critical hit", function()
            local result = player:takeDamage(20, true)  -- force crit
            assert.are.equal(40, result.damageDone)
            assert.is_true(result.wasCritical)
        end)

        it("does nothing if character is already dead", function()
            player:takeDamage(100)  -- kill
            local result = player:takeDamage(50)  -- hit dead character
            assert.are.equal(0, result.damageDone)
        end)

        it("ignores zero or negative damage", function()
            player:takeDamage(0)
            assert.are.equal(100, player:getHealth())

            player:takeDamage(-10)
            assert.are.equal(100, player:getHealth())
        end)

        it("returns died=true when killing blow lands", function()
            local result = player:takeDamage(100)
            assert.is_true(result.died)
        end)

    end)

    -- ── HEAL TESTS ────────────────────────────────────────
    describe("heal()", function()

        it("restores health correctly", function()
            player:takeDamage(50)
            player:heal(30)
            assert.are.equal(80, player:getHealth())
        end)

        it("does not exceed max health", function()
            player:takeDamage(10)
            player:heal(999)
            assert.are.equal(100, player:getHealth())
        end)

        it("cannot heal a dead character", function()
            player:takeDamage(100)
            local healed = player:heal(50)
            assert.are.equal(0, healed)
            assert.are.equal(0, player:getHealth())
        end)

        it("returns the actual amount healed", function()
            player:takeDamage(20)
            local healed = player:heal(10)
            assert.are.equal(10, healed)
        end)

    end)

    -- ── REVIVE TESTS ──────────────────────────────────────
    describe("revive()", function()

        it("brings a dead character back to life", function()
            player:takeDamage(100)
            player:revive()
            assert.is_false(player:isDead())
        end)

        it("revives with 50% health by default", function()
            player:takeDamage(100)
            player:revive()
            assert.are.equal(50, player:getHealth())
        end)

        it("revives with custom health percent", function()
            player:takeDamage(100)
            player:revive(1.0)
            assert.are.equal(100, player:getHealth())
        end)

    end)

    -- ── STATUS TESTS ──────────────────────────────────────
    describe("getStatus()", function()

        it("returns correct health percent", function()
            player:takeDamage(25)
            local status = player:getStatus()
            assert.are.equal(0.75, status.healthPercent)
        end)

        it("returns the correct name", function()
            local status = player:getStatus()
            assert.are.equal("Hero", status.name)
        end)

    end)

end)
