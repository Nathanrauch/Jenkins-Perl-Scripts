#!/usr/bin/perl
use Time::HiRes;
use Spreadsheet::WriteExcel;

my $excel_value = 1;
# This script tests CyaSSL. 

my $start = Time::HiRes::gettimeofday(); #start timer 
my $FileName = "/home/nathan/Desktop/Jenkins_Log/Report_$start.xls";
my $workbook = Spreadsheet::WriteExcel->new($FileName);
my $worksheet1 = $workbook->add_worksheet('PERL');

# this is the CyaSSL options list that will be tested. To add options just put them at the end. 
my @enableList = qw/--enable-dtls --disable-dtls --enable-opensslextra --disable-opensslextra --enable-leanpsk --disable-leanpsk --enable-savesession --disable-savesession 
                 --enable-savecert --disable-savecert --enable-atomicuser --disable-atomicuser --enable-pkcallbacks --disable-pkcallbacks --enable-aesgcm --disable-aesgcm 
                 --enable-aesni --disable-aesni --enable-camellia --disable-camellia --enable-md2 --disable-md2 --enable-nullcipher --disable-nullcipher                  
                 --enable-ripemd --disable-ripemd --enable-blake2 --disable-blake2 --enable-sha512 --disable-sha512 --enable-sessioncerts --disable-sessioncerts 
                 --enable-keygen --disable-keygen --enable-certgen --disable-certgen --enable-dsa --disable-dsa --enable-ecc --disable-ecc --enable-psk --disable-psk 
                 --disable-dh --enable-dh --disable-asn --enable-asn --disable-aes --enable-aes --disable-md5 --enable-md5 --disable-oldtls --enable-oldtls
                 --enable-sha  --disable-sha --enable-md4  --disable-md4 --enable-pwdbased --disable-pwdbased --enable-hc128 --disable-hc128 --enable-rabbit --disable-rabbit 
                 --enable-ocsp --disable-ocsp --enable-crl --disable-crl --disable-memory --enable-memory --disable-rsa --enable-rsa --disable-des3 --enable-des3 
                 --enable-sni --disable-sni --enable-maxfragment --disable-maxfragment --enable-truncatedhmac --disable-truncatedhmac --disable-arc4 --enable-arc4/;

my $TestCases = 3000;             # this sets the number of test cases the user wants to run.
my $Max_Opt_Num = 3 ;               # this sets the Max Number of options that can be tested in a test case. 
my $range = (scalar @enableList); # finds the length of the list of CyaSSL options so it makes it easier to add options later on.                  


    
print "\n";
setup();
random_testing();                   # test random configure options




sub random_testing 
{        
    my $Testing = 2;
    my $excel_count = 1;
    while ($Testing < $Max_Opt_Num) {
        my $COUNT = 0;
        my $Loop = 0;
        my @Array;

        print "\n";
        print "Testing: ". $Testing. "\n";
        
        while ($Loop < $TestCases) {
            print "Case:". $Loop. "\n";
            print "./configure ";

            while ($COUNT < $Testing){
                $Array[$COUNT] = $enableList[int(rand($range))]; # pick random option from the list and store it in an array
                print $Array[$COUNT]. " ";                       # display the option picked                   
                $COUNT=$COUNT+1;
            }
            my $num = 0;
            while ($num < $Testing){
                if($num == 0){
                   $worksheet1->write($excel_count ,$num, $Array[$num]);
                }
                else{
                    $worksheet1->write($excel_count ,$num +$num, $Array[$num]);
                }
                $num = $num +1;
            }
            
            `./configure @Array`; # configure CyaSSL with the random options
            my $conf = $?;
            print $conf;
            if($conf != 0){
                print "\n Configure Failed!!!\n";
            $worksheet1->write($excel_value,$Max_Opt_Num +6, "X");
            }
            else{
                print "\n";

                `make check`;          
                my $make = $?;         # get the return value from make check, check if it passed or failed. 

                if ($make != 0) {
                    $worksheet1->write($excel_value,$Max_Opt_Num +6, "X");
                    print "Make Check: Fail\n";
                } 
                else {

                    print " Make Check: Passed\n";
                    $worksheet1->write($excel_value,$Max_Opt_Num +5, "X");
                }
                print "\n";
                } 

            $excel_value = $excel_value +1;                                  # use random configure option to configure and make check CyaSSL 
            $Loop = $Loop + 1;
            $COUNT = 0;
            $excel_count = $excel_count +1;
            @array = NULL;
        }
        
        $Testing = $Testing + 1;  
    }
}

sub setup{
    $worksheet1->write(0,0, "Configure");
    $worksheet1->write(0,$Max_Opt_Num +5, "Pass");
    $worksheet1->write(0,$Max_Opt_Num +6, "Fail");

}
