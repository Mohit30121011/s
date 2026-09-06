package com.nlogistic.util;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Marks users whose access rights changed while they were logged in.
 *
 * The session carries a User object loaded at login, so a permission or role
 * change made in the Users &amp; Roles console had no effect until that person
 * happened to log out and back in. Revoking someone's access to Billing left
 * them using Billing for the rest of the day, which is the one case where the
 * delay actually matters.
 *
 * Polling the database on every request would fix it at the cost of a query per
 * hit. Instead the admin console drops the affected user id here, and
 * AuthenticationFilter reloads that one user's rights on their next request and
 * clears the mark. Nothing is queried for anybody else.
 *
 * This is per-JVM state, which matches how sessions are held here.
 */
public final class AccessRefresh {

    private static final Set<Integer> PENDING = ConcurrentHashMap.newKeySet();

    private AccessRefresh() {}

    /** Called after a role or module-permission change. */
    public static void mark(int userId) {
        PENDING.add(userId);
    }

    /** True once per change: consumes the mark. */
    public static boolean consume(int userId) {
        return PENDING.remove(userId);
    }
}
