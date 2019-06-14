classdef TestTls < matlab.unittest.TestCase
    % TestTls tests TLS connection scenarios.
    methods (Test)
        function testSecureConn(testCase)
            % secure connection test
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            testCase.verifyTrue(length(dj.conn(...
                testCase.CONN_INFO.host, ...
                testCase.CONN_INFO.user, ...
                testCase.CONN_INFO.password, ...
                '',true,true).query(...
                'SHOW STATUS LIKE ''Ssl_cipher''').Value{1}) > 0);
        end
        function testInsecureConn(testCase)
            % insecure connection test
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            testCase.verifyEqual(dj.conn(...
                testCase.CONN_INFO.host, ...
                testCase.CONN_INFO.user, ...
                testCase.CONN_INFO.password, ...
                '',true,false).query(...
                'SHOW STATUS LIKE ''Ssl_cipher''').Value{1}, ...
                '');
        end
        function testPreferredConn(testCase)
            % preferred connection test
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            testCase.verifyTrue(length(dj.conn(...
                testCase.CONN_INFO.host, ...
                testCase.CONN_INFO.user, ...
                testCase.CONN_INFO.password, ...
                '',true).query(...
                'SHOW STATUS LIKE ''Ssl_cipher''').Value{1}) > 0);
        end
        function testRejectException(testCase)
            % test exception on require TLS
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);

            try
                curr_conn = dj.conn(...
                    testCase.CONN_INFO.host, ...
                    'djssl', ...
                    'djssl', ...
                    '',true,false);
                testCase.verifyTrue(false);
            catch
                e = lasterror;
                testCase.verifyEqual(e.identifier, 'MySQL:Error');
                testCase.verifyTrue(contains(e.message,...
                    ["requires secure connection","Access denied"])); %MySQL8,MySQL5
            end
        end
        function testStructException(testCase)
            % test exception on TLS struct
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            testCase.verifyError(@() dj.conn(...
                testCase.CONN_INFO.host, ...
                testCase.CONN_INFO.user, ...
                testCase.CONN_INFO.password, ...
                '',true,struct('ca','fake/path/some/where')), ...
                'DataJoint:TLS:InvalidStruct');
        end
    end
end