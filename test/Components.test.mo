import Iter "mo:base/Iter";
import { test } "mo:test";
import DateTime "../src/DateTime";
import Components "../src/Components";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Types "../internal/Types";
import Time "mo:base/Time";
import TimeZone "../src/TimeZone";

test(
    "epoch",
    func() {
        let expected : Components.Components = {
            year = 1970;
            month = 1;
            day = 1;
            hour = 0;
            minute = 0;
            nanosecond = 0;
        };
        let actual = Components.epoch();
        assert (expected == actual);
    },
);

test(
    "compare",
    func() {
        let testCases = [
            {
                c1 = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                c2 = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                order = ? #equal;
            },
            {
                c1 = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                c2 = {
                    year = 1970;
                    month = 2;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                order = ? #less;
            },
            {
                c1 = {
                    year = 1970;
                    month = 2;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                c2 = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                order = ? #greater;
            },
            {
                c1 = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                c2 = {
                    year = 1970;
                    month = 2;
                    day = 30; // Invalid day
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                order = null;
            },
            {
                c1 = {
                    year = 1970;
                    month = 1;
                    day = 32; // Invalid day
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                c2 = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                order = null;
            },
        ];
        for (testCase in Iter.fromArray(testCases)) {
            let actual = Components.compare(testCase.c1, testCase.c2);
            assert (testCase.order == actual);
        };
    },
);

test(
    "toTime and fromTime",
    func() {
        let testCases = [
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                expected = ?0;
            },
            {
                components = {
                    year = 1990;
                    month = 11;
                    day = 12;
                    hour = 4;
                    minute = 2;
                    nanosecond = 12345;
                };
                expected = ?658_382_520_000_012_345;
            },
            {
                components = {
                    year = -10;
                    month = 3;
                    day = 4;
                    hour = 4;
                    minute = 1;
                    nanosecond = 2;
                };
                expected = ?-62_477_380_739_999_999_998;
            },
            {
                components = {
                    year = 2020;
                    month = 1;
                    day = 32; // Invalid day
                    hour = 4;
                    minute = 1;
                    nanosecond = 2;
                };
                expected = null;
            },
        ];
        for (testCase in Iter.fromArray(testCases)) {
            let actual : ?Time.Time = Components.toTime(testCase.components);
            let matched = testCase.expected == actual;
            if (not matched) {
                Debug.print("Expected: " # debug_show (testCase.expected));
                Debug.print("Actual:   " # debug_show (actual));
                assert false;
            };
            switch (actual) {
                case (null) {};
                case (?a) {
                    let actualComponents = Components.fromTime(a);
                    let matched2 = testCase.components == actualComponents;

                    if (not matched2) {
                        Debug.print("Expected: " # debug_show (testCase.components));
                        Debug.print("Actual:   " # debug_show (actualComponents));
                        assert false;
                    };
                };
            };
        };
    },
);

test(
    "isValid",
    func() {
        let testCases = [
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 2;
                    day = 28;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 2;
                    day = 29; // Invalid day
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = false;
            },
            {
                components = {
                    year = 2000;
                    month = 2;
                    day = 29; // Leap Day
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 23;
                    minute = 59;
                    nanosecond = 59_999_999_999;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 24; // Invalid hour
                    minute = 59;
                    nanosecond = 59_999_999_999;
                };
                isValid = false;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 23;
                    minute = 60; // Invalid minute
                    nanosecond = 59_999_999_999;
                };
                isValid = false;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 23;
                    minute = 59;
                    nanosecond = 60_000_000_000; // Invalid nanosecond
                };
                isValid = false;
            },
            {
                components = {
                    year = -1000;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
        ];
        for (testCase in Iter.fromArray(testCases)) {
            let actual : Bool = Components.isValid(testCase.components);
            let matched = testCase.isValid == actual;
            if (not matched) {
                Debug.print("Components: " # debug_show (testCase.components));
                Debug.print("Expected: " # debug_show (testCase.isValid));
                Debug.print("Actual:   " # debug_show (actual));
                assert false;
            };
        };
    },
);

test(
    "getOffsetSeconds",
    func() {
        let testCases = [
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 2;
                    day = 28;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 2;
                    day = 29; // Invalid day
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = false;
            },
            {
                components = {
                    year = 2000;
                    month = 2;
                    day = 29; // Leap Day
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 23;
                    minute = 59;
                    nanosecond = 59_999_999_999;
                };
                isValid = true;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 24; // Invalid hour
                    minute = 59;
                    nanosecond = 59_999_999_999;
                };
                isValid = false;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 23;
                    minute = 60; // Invalid minute
                    nanosecond = 59_999_999_999;
                };
                isValid = false;
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 23;
                    minute = 59;
                    nanosecond = 60_000_000_000; // Invalid nanosecond
                };
                isValid = false;
            },
            {
                components = {
                    year = -1000;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                isValid = true;
            },
        ];
        for (testCase in Iter.fromArray(testCases)) {
            let actual : Bool = Components.isValid(testCase.components);
            let matched = testCase.isValid == actual;
            if (not matched) {
                Debug.print("Components: " # debug_show (testCase.components));
                Debug.print("Expected: " # debug_show (testCase.isValid));
                Debug.print("Actual:   " # debug_show (actual));
                assert false;
            };
        };
    },
);


func assertText(expected : Text, actual : Text) {
    if (expected != actual) {
        Debug.print("Expected: " # debug_show (expected));
        Debug.print("Actual:   " # debug_show (actual));
        assert false;
    };
};

test(
    "toTextFormatted and fromTextFormatted",
    func() {
        let testCases = [
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                timeZoneDescriptor = #utc;
                expectedIso8601 = "1970-01-01T00:00:00.000Z";
            },
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                timeZoneDescriptor = #hoursAndMinutes(-7, 2);
                expectedIso8601 = "1970-01-01T00:00:00.000-07:02";
            },
        ];
        for (testCase in Iter.fromArray(testCases)) {
            let actual : Text = Components.toTextFormatted(testCase.components, testCase.timeZoneDescriptor, #iso8601);
            assertText(testCase.expectedIso8601, actual);

            let fromTextResult = Components.fromTextFormatted(testCase.expectedIso8601, #iso8601);
            switch (fromTextResult) {
                case (null) {
                    Debug.print("Failed to parse ISO 8601 datetime: " # debug_show (testCase.expectedIso8601));
                    assert false;
                };
                case (?r) {            
                    let matched2 = testCase.components == r.components
                        and testCase.timeZoneDescriptor == r.timeZoneDescriptor;

                    if (not matched2) {
                        Debug.print("Text: " # debug_show (testCase.expectedIso8601));
                        Debug.print("Expected: " # debug_show (testCase.components) # " - " # debug_show (testCase.timeZoneDescriptor));
                        Debug.print("Actual:   " # debug_show (r.components) # " - " # debug_show (r.timeZoneDescriptor));
                        assert false;
                    };
                }
            };
        };
    },
);


test(
    "addTime",
    func() {
        let testCases = [
            {
                components = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                timeToAdd = 123;
                expectedComponents = {
                    year = 1970;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 123;
                };
            },
            {
                components = {
                    year = 1980;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                timeToAdd = 123_456_789_012_345_678;
                expectedComponents = {
                    year = 1983;
                    month = 11;
                    day = 29;
                    hour = 21;
                    minute = 33;
                    nanosecond = 9_012_345_678;
                };
            },
            {
                components = {
                    year = 1971;
                    month = 1;
                    day = 1;
                    hour = 0;
                    minute = 0;
                    nanosecond = 0;
                };
                timeToAdd = -123_456_789_012_345_678;
                expectedComponents = {
                    year = 1967;
                    month = 2;
                    day = 2;
                    hour = 2;
                    minute = 26;
                    nanosecond = 50_987_654_322;
                };
            }
        ];
        for (testCase in Iter.fromArray(testCases)) {
            let actual : Components.Components = Components.addTime(testCase.components, testCase.timeToAdd);
            let matched = testCase.expectedComponents == actual;
            if (not matched) {
                Debug.print("Components: " # debug_show (testCase.components));
                Debug.print("Time to add: " # debug_show (testCase.timeToAdd));
                Debug.print("Expected: " # debug_show (testCase.expectedComponents));
                Debug.print("Actual:   " # debug_show (actual));
                assert false;
            };
        };
    },
);