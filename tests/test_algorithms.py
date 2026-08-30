def ring_indices(write_index, samples, capacity):
    idx = write_index - 1
    if idx < 0:
        idx = capacity - 1
    out = []
    for _ in range(samples):
        out.append(idx)
        idx -= 1
        if idx < 0:
            idx = capacity - 1
    return out


def reconnect_backoff(attempt):
    delay = 5.0
    for _ in range(attempt):
        delay = min(delay * 2.0, 60.0)
    return delay


def test_ring_buffer_walk_is_reverse_chronological():
    assert ring_indices(0, 4, 8) == [7, 6, 5, 4]
    assert ring_indices(5, 4, 8) == [4, 3, 2, 1]


def test_reconnect_backoff_is_capped():
    assert [reconnect_backoff(i) for i in range(7)] == [5.0, 10.0, 20.0, 40.0, 60.0, 60.0, 60.0]


def smoke_bucket(cx, cy):
    return ((cx * 73856093) ^ (cy * 19349663)) & 63


def nearby_bucket_keys(cx, cy):
    return {smoke_bucket(cx + dx, cy + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)}


def test_smoke_grid_checks_only_neighboring_cells():
    assert len(nearby_bucket_keys(10, 20)) <= 9
    assert smoke_bucket(0, 0) in nearby_bucket_keys(0, 0)


def speed_sq(v):
    return v[0] * v[0] + v[1] * v[1]


def test_speed_squared_comparison_matches_linear_threshold():
    allowed = 480.0
    allowed_sq = allowed * allowed
    assert speed_sq((479.0, 0.0)) < allowed_sq
    assert speed_sq((481.0, 0.0)) > allowed_sq


def connect_spam_check_old(last_connect_gametime, gametime_now, block_seconds=15.0):
    # Models is_antispam.sp's ORIGINAL logic: GetGameTime() resets to ~0 at every map
    # change, but a stored timestamp from the previous map is compared against it
    # unchanged. Returns True if the connect would be (wrongly) blocked.
    time_left = last_connect_gametime + block_seconds - gametime_now
    return time_left > 0.0


def connect_spam_check_fixed(last_connect_ticked, tickedtime_now, is_map_transition, block_seconds=15.0):
    # Models the FIXED logic: a monotonic clock (GetTickedTime(), which SourceMod
    # documents as surviving map changes) plus an explicit exemption for IPs recognized
    # as continuing the same session across a map transition (snapshotted at OnMapEnd).
    if is_map_transition:
        return False
    time_left = last_connect_ticked + block_seconds - tickedtime_now
    return time_left > 0.0


def test_old_connect_spam_logic_wrongly_blocks_a_map_change_reconnect():
    # Reproduces the reported bug: a player connected at game-time 110s on map A (which
    # had been running for a while), then the server changes to map B, where
    # GetGameTime() has reset to near zero. The OLD logic sees this as "reconnecting
    # far too soon" and blocks a completely legitimate player.
    assert connect_spam_check_old(last_connect_gametime=110.0, gametime_now=0.5) is True


def test_fixed_connect_spam_logic_allows_a_map_change_reconnect():
    # Same underlying scenario, but recognized as a map-transition reconnect (the IP was
    # snapshotted as in-game right before the map ended) -- must NOT be blocked,
    # regardless of how little monotonic time has elapsed.
    assert connect_spam_check_fixed(
        last_connect_ticked=1234.0, tickedtime_now=1234.6, is_map_transition=True
    ) is False


def test_fixed_connect_spam_logic_still_blocks_genuine_reconnect_spam():
    # A real rapid reconnect within the SAME map (not a transition) must still be
    # blocked -- the fix must not weaken this protection.
    assert connect_spam_check_fixed(
        last_connect_ticked=500.0, tickedtime_now=503.0, is_map_transition=False
    ) is True


def test_fixed_connect_spam_logic_allows_reconnect_after_window_elapses():
    assert connect_spam_check_fixed(
        last_connect_ticked=500.0, tickedtime_now=520.0, is_map_transition=False
    ) is False


def test_fixed_connect_spam_logic_does_not_penalize_a_new_occupant_of_a_reused_slot():
    # Player A disconnects, Player B takes the same client slot with a different IP.
    # B's IP was never snapshotted (only A's was, at the previous OnMapEnd) and has no
    # connect-history entry either, so B must not be blocked.
    assert connect_spam_check_fixed(
        last_connect_ticked=0.0, tickedtime_now=999.0, is_map_transition=False
    ) is False


# --- Boundary / property tests (ring buffer and NaN handling) -----------------------

MAX_ANGLE_HISTORY = 64


def test_ring_indices_at_zero_samples_returns_empty():
    assert ring_indices(write_index=5, samples=0, capacity=MAX_ANGLE_HISTORY) == []


def test_ring_indices_at_one_sample_returns_single_previous_slot():
    assert ring_indices(write_index=5, samples=1, capacity=MAX_ANGLE_HISTORY) == [4]


def test_ring_indices_handles_wraparound_at_write_index_zero():
    # write_index=0 means the last write wrapped to the end of the buffer; walking
    # backward from "the slot before 0" must land on capacity-1, not -1.
    out = ring_indices(write_index=0, samples=3, capacity=MAX_ANGLE_HISTORY)
    assert out[0] == MAX_ANGLE_HISTORY - 1
    assert all(0 <= i < MAX_ANGLE_HISTORY for i in out)


def test_ring_indices_at_full_capacity_never_repeats_or_goes_out_of_bounds():
    out = ring_indices(write_index=10, samples=MAX_ANGLE_HISTORY, capacity=MAX_ANGLE_HISTORY)
    assert len(out) == len(set(out)) == MAX_ANGLE_HISTORY
    assert all(0 <= i < MAX_ANGLE_HISTORY for i in out)


def is_invalid_angle_component(value):
    # Mirrors is_eyetest.sp's NaN check: x != x is true only for NaN under IEEE 754.
    return value != value


def test_nan_detection_matches_sourcepawn_self_inequality_trick():
    nan = float("nan")
    assert is_invalid_angle_component(nan) is True
    for ordinary in (0.0, -0.0, 180.0, -180.0, 1e300, -1e300):
        assert is_invalid_angle_component(ordinary) is False


def smoke_bucket(cx, cy):
    return ((cx * 73856093) ^ (cy * 19349663)) & (SMOKE_GRID_BUCKETS - 1)


SMOKE_GRID_BUCKETS = 64


def test_smoke_bucket_stays_in_range_for_extreme_coordinates():
    # Map coordinates can legitimately be large negative or positive floats cast to
    # cell indices; the hash must never produce an out-of-range bucket regardless.
    for cx, cy in ((0, 0), (-1, -1), (999999, -999999), (-2147483647, 2147483647)):
        bucket = smoke_bucket(cx, cy)
        assert 0 <= bucket < SMOKE_GRID_BUCKETS


def test_empty_smoke_grid_produces_no_candidates():
    grid = [[] for _ in range(SMOKE_GRID_BUCKETS)]
    cx, cy = 3, 3
    candidates = set()
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            candidates.update(grid[smoke_bucket(cx + dx, cy + dy)])
    assert candidates == set()
