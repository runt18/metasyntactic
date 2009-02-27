// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "Model.h"

#import "Amendment.h"
#import "Article.h"
#import "Constitution.h"
#import "Decision.h"
#import "DeclarationOfIndependence.h"
#import "LocaleUtilities.h"
#import "MultiDictionary.h"
#import "Person.h"
#import "RSSCache.h"
#import "Section.h"
#import "Utilities.h"

@interface Model()
@property (retain) RSSCache* rssCache;
@end

@implementation Model

static NSArray* sectionTitles;
static NSArray* shortSectionTitles;
static NSArray* questions;
static NSArray* answers;
static NSArray* preambles;
static NSArray* otherResources;
static NSArray* sectionLinks;
static NSArray* links;

static NSArray* toughQuestions;
static NSArray* toughAnswers;

static NSString* currentVersion = @"1.4.0";

static Constitution* unitedStatesConstitution;
static Constitution* articlesOfConfederation;
static Constitution* federalistPapers;
static DeclarationOfIndependence* declarationOfIndependence;

+ (NSString*) version {
    return currentVersion;
}


Person* person(NSString* name, NSString* link) {
    return [Person personWithName:name link:link];
}


+ (void) setupToughQuestions {
    toughQuestions =
    [[NSArray arrayWithObjects:
      NSLocalizedString(@"Why do you defend Nazis and the Klan?", nil),
      NSLocalizedString(@"You’re all a bunch of liberals, aren’t you?", nil),
      NSLocalizedString(@"Why does the ACLU support cross burning?", nil),
      NSLocalizedString(@"Why does the ACLU support pornography? Why are you in favor of child porn?", nil),
      NSLocalizedString(@"Why doesn’t the ACLU support gun ownership/gun control?", nil),
      NSLocalizedString(@"Why does the ACLU support the rights of criminals but not victims of crime?", nil),
      NSLocalizedString(@"Why is the ACLU against God/Christianity/the Bible?", nil),
      NSLocalizedString(@"Why is the ACLU against drug testing of employees?", nil),
      NSLocalizedString(@"Why does the ACLU help rapists and child molesters?", nil),
      NSLocalizedString(@"Why did the ACLU defend NAMBLA?", nil), nil] retain];
    
    toughAnswers =
    [[NSArray arrayWithObjects:
      NSLocalizedString(@"The ACLU’s client is the Bill of Rights, not any particular person or group. We defend its principles – basic "
                        @"rights of citizens – whenever these are threatened. We do not believe that you can pick and chose when to "
                        @"uphold rights. If a right can be taken away from one person, it can be taken away from anyone. When you deny "
                        @"a right to someone with whom you disagree, you pave the way for that right to be denied to yourself or someone "
                        @"whom you strongly support. For example, the principle by which the Ku Klux Klan has the right to march is the "
                        @"same one that allows civil rights activists to march against racism.", nil),
      NSLocalizedString(@"The ACLU is a nonpartisan group. We have defended and worked with people all across the political spectrum, "
                        @"from Rev. Jerry Falwell and Oliver North to radio host Rush Limbaugh and former Republican member of "
                        @"Congress Bob Barr. The ACLU strongly supports women’s right to choose abortion, yet we have also assisted "
                        @"anti-abortion activists when police used excessive force in arresting them. The ACLU has won support from "
                        @"women’s groups for our stand on women’s rights, but has angered some feminists for our First Amendment "
                        @"stand on pornography.", nil),
      NSLocalizedString(@"The ACLU condemns all forms of racism. However, the ACLU does believe that in some specific cases, the "
                        @"First Amendment protects the burning of a cross. People have the right to be bigots and to make extreme, "
                        @"symbolic statements of their bigotry. Burning a cross on one’s own lawn in the middle of the day without "
                        @"making specific threats against anybody is an example of this. That’s why the ACLU opposes laws that say any "
                        @"and all instances of cross burning are illegal. Such laws are too broad and vague and have the result of "
                        @"preventing people from exercising their rights to free speech. As an answer to racist speech, the ACLU "
                        @"advocates more speech directed against racism, not the suppression of speech.", nil),
      NSLocalizedString(@"The ACLU does not support pornography. But we do oppose virtually all forms of censorship. Possessing "
                        @"books or films should not make one a criminal. Once society starts censoring “bad” ideas, it becomes very "
                        @"difficult to draw the line. Your idea of what is offensive may be a lot different from your neighbor’s. In fact, the "
                        @"ACLU does take a very purist approach in opposing censorship. Our policy is that possessing even "
                        @"pornographic material about children should not itself be a crime. The way to deal with this issue is to prosecute "
                        @"the makers of child pornography for exploiting minors.", nil),
      NSLocalizedString(@"The national ACLU is neutral on the issue of gun control. We believe the Second Amendment does not confer "
                        @"an unlimited right upon individuals to own guns or other weapons, nor does it prohibit reasonable regulation of "
                        @"gun ownership, such as licensing and registration. This, like all ACLU policies, is set by the board of directors, "
                        @"a group of ACLU members.", nil),
      NSLocalizedString(@"The ACLU supports everybody’s rights. Citizens are outraged by crime and understandably want criminals "
                        @"caught and prosecuted. The ACLU simply believes that the rights to fair treatment and due process must be "
                        @"respected for people accused of crimes. Respecting these rights does not cause crime, nor does it hinder police "
                        @"from pursuing criminals. It should, and does in fact, cause police to avoid sloppy procedures.", nil),
      NSLocalizedString(@"The ACLU strongly supports our country’s guarantee that all people have the right to practice their own "
                        @"religion, as well as the right not to practice any religion. The best way to ensure religious freedom for all is to "
                        @"keep the government out of the business of pushing religion on anybody. The ACLU strongly supports the "
                        @"separation of church and state. In practice, this means that people may practice their religion – just not with "
                        @"government funding or sponsorship. This simple principle in no way banishes or weakens religion. It only "
                        @"means that no one should have somebody else’s religion forced on him or her, even if most other people in a "
                        @"community support that religion.", nil),
      NSLocalizedString(@"The ACLU, of course, believes that employers have the right to discipline and fire workers who fail to perform "
                        @"on the job. However, the ACLU does oppose indiscriminate urine testing because the process is both unfair and "
                        @"unnecessary. Having someone urinate in a cup is a degrading and uncertain procedure that violates personal "
                        @"privacy. Further, drug tests do not measure impaired job performance. A positive drug test simply indicates that "
                        @"a person may have taken drugs at some time in the past – not that they are failing to perform properly in their "
                        @"assigned work. And the accuracy of some drug tests is notoriously unreliable. The ACLU especially objects to "
                        @"mass random drug testing of workers. There is no reason that a person should have to prove he or she is "
                        @"“innocent” of taking drugs when there is no evidence that he or she has done so. In general, what workers do off "
                        @"the job should be their own business so long as they are performing satisfactorily at work.", nil),
      NSLocalizedString(@"Of course, the ACLU supports the prosecution and conviction of rapists and child molesters. They should "
                        @"receive appropriate punishment – especially for repeat offenders. But like all convicted felons, they are entitled "
                        @"to some basic constitutional protections. In this regard the ACLU opposes the Community Protection Act "
                        @"passed by the Washington Legislature. It calls for locking up an individual indefinitely – potentially for life – "
                        @"after he has served his prison term. The punishment is based not on additional wrongful acts, but on speculation "
                        @"that the person may commit illegal acts in the future. This is unconstitutional preventive detention. It is based on "
                        @"the unscientific notion that society can predict with any reasonable standard of accuracy how a particular "
                        @"individual will act at some unspecified time.", nil),
      NSLocalizedString(@"In representing NAMBLA, the ACLU does not advocate sexual relationships between adults and children. In "
                        @"celebrated cases, the ACLU has stood up for everyone from Oliver North to the National Socialist Party. In "
                        @"spite of all that, the ACLU has never advocated Christianity, ritual animal sacrifice, trading arms for hostages or "
                        @"genocide. What we do advocate is robust freedom of speech. This lawsuit strikes at the heart of freedom of "
                        @"speech. The defense of freedom of speech is most critical when the message is one most people find repulsive. "
                        @"The case is based on a shocking murder. But the lawsuit says the crime is the responsibility not of those who "
                        @"committed the murder, but of someone who posted vile material on the Internet. The principle is as simple as it "
                        @"is central to true freedom of speech: those who do wrong are responsible for what they do; those who speak "
                        @"about it are not. It is easy to defend freedom of speech when the message is something many people find at least "
                        @"reasonable. But the defense of freedom of speech is most critical when the message is one most people find "
                        @"repulsive. That was true when the Nazis marched in Skokie. It remains true today.", nil), nil] retain];
}


+ (Constitution*) setupUnitedStatesConstitution {
    NSString* country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:@"US"];
    Article* article1 =
    [Article articleWithTitle:NSLocalizedString(@"The Legislative Branch", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_One_of_the_United_States_Constitution"
                     sections:[NSArray arrayWithObjects:
                               [Section sectionWithText:NSLocalizedString(@"All legislative powers herein granted shall be vested in a Congress of the United States, which shall consist of a Senate and House of Representatives.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The House of Representatives shall be composed of members chosen every second year by the people of the several states, and the electors in each state shall have the qualifications requisite for electors of the most numerous branch of the state legislature.\n\n"
                                                                          @"No person shall be a Representative who shall not have attained to the age of twenty five years, and been seven years a citizen of the United States, and who shall not, when elected, be an inhabitant of that state in which he shall be chosen.\n\n"
                                                                          @"Representatives and direct taxes shall be apportioned among the several states which may be included within this union, according to their respective numbers, which shall be determined by adding to the whole number of free persons, including those bound to service for a term of years, and excluding Indians not taxed, three fifths of all other Persons. The actual Enumeration shall be made within three years after the first meeting of the Congress of the United States, and within every subsequent term of ten years, in such manner as they shall by law direct. The number of Representatives shall not exceed one for every thirty thousand, but each state shall have at least one Representative; and until such enumeration shall be made, the state of New Hampshire shall be entitled to chuse three, Massachusetts eight, Rhode Island and Providence Plantations one, Connecticut five, New York six, New Jersey four, Pennsylvania eight, Delaware one, Maryland six, Virginia ten, North Carolina five, South Carolina five, and Georgia three.\n\n"
                                                                          @"When vacancies happen in the Representation from any state, the executive authority thereof shall issue writs of election to fill such vacancies.\n\n"
                                                                          @"The House of Representatives shall choose their speaker and other officers; and shall have the sole power of impeachment.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The Senate of the United States shall be composed of two Senators from each state, chosen by the legislature thereof, for six years; and each Senator shall have one vote.\n\n"
                                                                          @"Immediately after they shall be assembled in consequence of the first election, they shall be divided as equally as may be into three classes. The seats of the Senators of the first class shall be vacated at the expiration of the second year, of the second class at the expiration of the fourth year, and the third class at the expiration of the sixth year, so that one third may be chosen every second year; and if vacancies happen by resignation, or otherwise, during the recess of the legislature of any state, the executive thereof may make temporary appointments until the next meeting of the legislature, which shall then fill such vacancies.\n\n"
                                                                          @"No person shall be a Senator who shall not have attained to the age of thirty years, and been nine years a citizen of the United States and who shall not, when elected, be an inhabitant of that state for which he shall be chosen.\n\n"
                                                                          @"The Vice President of the United States shall be President of the Senate, but shall have no vote, unless they be equally divided.\n\n"
                                                                          @"The Senate shall choose their other officers, and also a President pro tempore, in the absence of the Vice President, or when he shall exercise the office of President of the United States.\n\n"
                                                                          @"The Senate shall have the sole power to try all impeachments. When sitting for that purpose, they shall be on oath or affirmation. When the President of the United States is tried, the Chief Justice shall preside: And no person shall be convicted without the concurrence of two thirds of the members present.\n\n"
                                                                          @"Judgment in cases of impeachment shall not extend further than to removal from office, and disqualification to hold and enjoy any office of honor, trust or profit under the United States: but the party convicted shall nevertheless be liable and subject to indictment, trial, judgment and punishment, according to law.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The times, places and manner of holding elections for Senators and Representatives, shall be prescribed in each state by the legislature thereof; but the Congress may at any time by law make or alter such regulations, except as to the places of choosing Senators.\n\n"
                                                                          @"The Congress shall assemble at least once in every year, and such meeting shall be on the first Monday in December, unless they shall by law appoint a different day.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"Each House shall be the judge of the elections, returns and qualifications of its own members, and a majority of each shall constitute a quorum to do business; but a smaller number may adjourn from day to day, and may be authorized to compel the attendance of absent members, in such manner, and under such penalties as each House may provide.\n\n"
                                                                          @"Each House may determine the rules of its proceedings, punish its members for disorderly behavior, and, with the concurrence of two thirds, expel a member.\n\n"
                                                                          @"Each House shall keep a journal of its proceedings, and from time to time publish the same, excepting such parts as may in their judgment require secrecy; and the yeas and nays of the members of either House on any question shall, at the desire of one fifth of those present, be entered on the journal.\n\n"
                                                                          @"Neither House, during the session of Congress, shall, without the consent of the other, adjourn for more than three days, nor to any other place than that in which the two Houses shall be sitting.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The Senators and Representatives shall receive a compensation for their services, to be ascertained by law, and paid out of the treasury of the United States. They shall in all cases, except treason, felony and breach of the peace, be privileged from arrest during their attendance at the session of their respective Houses, and in going to and returning from the same; and for any speech or debate in either House, they shall not be questioned in any other place.\n\n"
                                                                          @"No Senator or Representative shall, during the time for which he was elected, be appointed to any civil office under the authority of the United States, which shall have been created, or the emoluments whereof shall have been increased during such time: and no person holding any office under the United States, shall be a member of either House during his continuance in office.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"All bills for raising revenue shall originate in the House of Representatives; but the Senate may propose or concur with amendments as on other Bills.\n\n"
                                                                          @"Every bill which shall have passed the House of Representatives and the Senate, shall, before it become a law, be presented to the President of the United States; if he approve he shall sign it, but if not he shall return it, with his objections to that House in which it shall have originated, who shall enter the objections at large on their journal, and proceed to reconsider it. If after such reconsideration two thirds of that House shall agree to pass the bill, it shall be sent, together with the objections, to the other House, by which it shall likewise be reconsidered, and if approved by two thirds of that House, it shall become a law. But in all such cases the votes of both Houses shall be determined by yeas and nays, and the names of the persons voting for and against the bill shall be entered on the journal of each House respectively. If any bill shall not be returned by the President within ten days (Sundays excepted) after it shall have been presented to him, the same shall be a law, in like manner as if he had signed it, unless the Congress by their adjournment prevent its return, in which case it shall not be a law.\n\n"
                                                                          @"Every order, resolution, or vote to which the concurrence of the Senate and House of Representatives may be necessary (except on a question of adjournment) shall be presented to the President of the United States; and before the same shall take effect, shall be approved by him, or being disapproved by him, shall be repassed by two thirds of the Senate and House of Representatives, according to the rules and limitations prescribed in the case of a bill.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The Congress shall have power to lay and collect taxes, duties, imposts and excises, to pay the debts and provide for the common defense and general welfare of the United States; but all duties, imposts and excises shall be uniform throughout the United States;\n\n"
                                                                          @"To borrow money on the credit of the United States;\n\n"
                                                                          @"To regulate commerce with foreign nations, and among the several states, and with the Indian tribes;\n\n"
                                                                          @"To establish a uniform rule of naturalization, and uniform laws on the subject of bankruptcies throughout the United States;\n\n"
                                                                          @"To coin money, regulate the value thereof, and of foreign coin, and fix the standard of weights and measures;\n\n"
                                                                          @"To provide for the punishment of counterfeiting the securities and current coin of the United States;\n\n"
                                                                          @"To establish post offices and post roads;\n\n"
                                                                          @"To promote the progress of science and useful arts, by securing for limited times to authors and inventors the exclusive right to their respective writings and discoveries;\n\n"
                                                                          @"To constitute tribunals inferior to the Supreme Court;\n\n"
                                                                          @"To define and punish piracies and felonies committed on the high seas, and offenses against the law of nations;\n\n"
                                                                          @"To declare war, grant letters of marque and reprisal, and make rules concerning captures on land and water;\n\n"
                                                                          @"To raise and support armies, but no appropriation of money to that use shall be for a longer term than two years;\n\n"
                                                                          @"To provide and maintain a navy;\n\n"
                                                                          @"To make rules for the government and regulation of the land and naval forces;\n\n"
                                                                          @"To provide for calling forth the militia to execute the laws of the union, suppress insurrections and repel invasions;\n\n"
                                                                          @"To provide for organizing, arming, and disciplining, the militia, and for governing such part of them as may be employed in the service of the United States, reserving to the states respectively, the appointment of the officers, and the authority of training the militia according to the discipline prescribed by Congress;\n\n"
                                                                          @"To exercise exclusive legislation in all cases whatsoever, over such District (not exceeding ten miles square) as may, by cession of particular states, and the acceptance of Congress, become the seat of the government of the United States, and to exercise like authority over all places purchased by the consent of the legislature of the state in which the same shall be, for the erection of forts, magazines, arsenals, dockyards, and other needful buildings;--And\n\n"
                                                                          @"To make all laws which shall be necessary and proper for carrying into execution the foregoing powers, and all other powers vested by this Constitution in the government of the United States, or in any department or officer thereof.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The migration or importation of such persons as any of the states now existing shall think proper to admit, shall not be prohibited by the Congress prior to the year one thousand eight hundred and eight, but a tax or duty may be imposed on such importation, not exceeding ten dollars for each person.\n\n"
                                                                          @"The privilege of the writ of habeas corpus shall not be suspended, unless when in cases of rebellion or invasion the public safety may require it.\n\n"
                                                                          @"No bill of attainder or ex post facto Law shall be passed.\n\n"
                                                                          @"No capitation, or other direct, tax shall be laid, unless in proportion to the census or enumeration herein before directed to be taken.\n\n"
                                                                          @"No tax or duty shall be laid on articles exported from any state.\n\n"
                                                                          @"No preference shall be given by any regulation of commerce or revenue to the ports of one state over those of another: nor shall vessels bound to, or from, one state, be obliged to enter, clear or pay duties in another.\n\n"
                                                                          @"No money shall be drawn from the treasury, but in consequence of appropriations made by law; and a regular statement and account of receipts and expenditures of all public money shall be published from time to time.\n\n"
                                                                          @"No title of nobility shall be granted by the United States: and no person holding any office of profit or trust under them, shall, without the consent of the Congress, accept of any present, emolument, office, or title, of any kind whatever, from any king, prince, or foreign state.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"No state shall enter into any treaty, alliance, or confederation; grant letters of marque and reprisal; coin money; emit bills of credit; make anything but gold and silver coin a tender in payment of debts; pass any bill of attainder, ex post facto law, or law impairing the obligation of contracts, or grant any title of nobility.\n\n"
                                                                          @"No state shall, without the consent of the Congress, lay any imposts or duties on imports or exports, except what may be absolutely necessary for executing it's inspection laws: and the net produce of all duties and imposts, laid by any state on imports or exports, shall be for the use of the treasury of the United States; and all such laws shall be subject to the revision and control of the Congress.\n\n"
                                                                          @"No state shall, without the consent of Congress, lay any duty of tonnage, keep troops, or ships of war in time of peace, enter into any agreement or compact with another state, or with a foreign power, or engage in war, unless actually invaded, or in such imminent danger as will not admit of delay.", nil)], nil]];
    
    Article* article2 =
    [Article articleWithTitle:NSLocalizedString(@"The Presidency", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_Two_of_the_United_States_Constitution"
                     sections:[NSArray arrayWithObjects:
                               [Section sectionWithText:NSLocalizedString(@"The executive power shall be vested in a President of the United States of America. He shall hold his office during the term of four years, and, together with the Vice President, chosen for the same term, be elected, as follows:\n\n"
                                                                          @"Each state shall appoint, in such manner as the Legislature thereof may direct, a number of electors, equal to the whole number of Senators and Representatives to which the State may be entitled in the Congress: but no Senator or Representative, or person holding an office of trust or profit under the United States, shall be appointed an elector.\n\n"
                                                                          @"The electors shall meet in their respective states, and vote by ballot for two persons, of whom one at least shall not be an inhabitant of the same state with themselves. And they shall make a list of all the persons voted for, and of the number of votes for each; which list they shall sign and certify, and transmit sealed to the seat of the government of the United States, directed to the President of the Senate. The President of the Senate shall, in the presence of the Senate and House of Representatives, open all the certificates, and the votes shall then be counted. The person having the greatest number of votes shall be the President, if such number be a majority of the whole number of electors appointed; and if there be more than one who have such majority, and have an equal number of votes, then the House of Representatives shall immediately choose by ballot one of them for President; and if no person have a majority, then from the five highest on the list the said House shall in like manner choose the President. But in choosing the President, the votes shall be taken by States, the representation from each state having one vote; A quorum for this purpose shall consist of a member or members from two thirds of the states, and a majority of all the states shall be necessary to a choice. In every case, after the choice of the President, the person having the greatest number of votes of the electors shall be the Vice President. But if there should remain two or more who have equal votes, the Senate shall choose from them by ballot the Vice President.\n\n"
                                                                          @"The Congress may determine the time of choosing the electors, and the day on which they shall give their votes; which day shall be the same throughout the United States.\n\n"
                                                                          @"No person except a natural born citizen, or a citizen of the United States, at the time of the adoption of this Constitution, shall be eligible to the office of President; neither shall any person be eligible to that office who shall not have attained to the age of thirty five years, and been fourteen Years a resident within the United States.\n\n"
                                                                          @"In case of the removal of the President from office, or of his death, resignation, or inability to discharge the powers and duties of the said office, the same shall devolve on the Vice President, and the Congress may by law provide for the case of removal, death, resignation or inability, both of the President and Vice President, declaring what officer shall then act as President, and such officer shall act accordingly, until the disability be removed, or a President shall be elected.\n\n"
                                                                          @"The President shall, at stated times, receive for his services, a compensation, which shall neither be increased nor diminished during the period for which he shall have been elected, and he shall not receive within that period any other emolument from the United States, or any of them.\n\n"
                                                                          @"Before he enter on the execution of his office, he shall take the following oath or affirmation:--'I do solemnly swear (or affirm) that I will faithfully execute the office of President of the United States, and will to the best of my ability, preserve, protect and defend the Constitution of the United States.'", nil)],           
                               [Section sectionWithText:NSLocalizedString(@"The President shall be commander in chief of the Army and Navy of the United States, and of the militia of the several states, when called into the actual service of the United States; he may require the opinion, in writing, of the principal officer in each of the executive departments, upon any subject relating to the duties of their respective offices, and he shall have power to grant reprieves and pardons for offenses against the United States, except in cases of impeachment.\n\n"
                                                                          @"He shall have power, by and with the advice and consent of the Senate, to make treaties, provided two thirds of the Senators present concur; and he shall nominate, and by and with the advice and consent of the Senate, shall appoint ambassadors, other public ministers and consuls, judges of the Supreme Court, and all other officers of the United States, whose appointments are not herein otherwise provided for, and which shall be established by law: but the Congress may by law vest the appointment of such inferior officers, as they think proper, in the President alone, in the courts of law, or in the heads of departments.\n\n"
                                                                          @"The President shall have power to fill up all vacancies that may happen during the recess of the Senate, by granting commissions which shall expire at the end of their next session.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"He shall from time to time give to the Congress information of the state of the union, and recommend to their consideration such measures as he shall judge necessary and expedient; he may, on extraordinary occasions, convene both Houses, or either of them, and in case of disagreement between them, with respect to the time of adjournment, he may adjourn them to such time as he shall think proper; he shall receive ambassadors and other public ministers; he shall take care that the laws be faithfully executed, and shall commission all the officers of the United States.", nil)], 
                               [Section sectionWithText:NSLocalizedString(@"The President, Vice President and all civil officers of the United States, shall be removed from office on impeachment for, and conviction of, treason, bribery, or other high crimes and misdemeanors.", nil)], nil]];
    
    Article* article3 =
    [Article articleWithTitle:NSLocalizedString(@"The Judiciary", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_Three_of_the_United_States_Constitution"
                     sections:[NSArray arrayWithObjects:
                               [Section sectionWithText:NSLocalizedString(@"The judicial power of the United States, shall be vested in one Supreme Court, and in such inferior courts as the Congress may from time to time ordain and establish. The judges, both of the supreme and inferior courts, shall hold their offices during good behaviour, and shall, at stated times, receive for their services, a compensation, which shall not be diminished during their continuance in office.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The judicial power shall extend to all cases, in law and equity, arising under this Constitution, the laws of the United States, and treaties made, or which shall be made, under their authority;--to all cases affecting ambassadors, other public ministers and consuls;--to all cases of admiralty and maritime jurisdiction;--to controversies to which the United States shall be a party;--to controversies between two or more states;--between a state and citizens of another state;--between citizens of different states;--between citizens of the same state claiming lands under grants of different states, and between a state, or the citizens thereof, and foreign states, citizens or subjects.\n\n"
                                                                          @"In all cases affecting ambassadors, other public ministers and consuls, and those in which a state shall be party, the Supreme Court shall have original jurisdiction. In all the other cases before mentioned, the Supreme Court shall have appellate jurisdiction, both as to law and fact, with such exceptions, and under such regulations as the Congress shall make.\n\n"
                                                                          @"The trial of all crimes, except in cases of impeachment, shall be by jury; and such trial shall be held in the state where the said crimes shall have been committed; but when not committed within any state, the trial shall be at such place or places as the Congress may by law have directed.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"Treason against the United States, shall consist only in levying war against them, or in adhering to their enemies, giving them aid and comfort. No person shall be convicted of treason unless on the testimony of two witnesses to the same overt act, or on confession in open court.\n\n"
                                                                          @"The Congress shall have power to declare the punishment of treason, but no attainder of treason shall work corruption of blood, or forfeiture except during the life of the person attainted.", nil)],
                               nil]];
    
    Article* article4 =
    [Article articleWithTitle:NSLocalizedString(@"The States", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_Four_of_the_United_States_Constitution"
                     sections:[NSArray arrayWithObjects:
                               [Section sectionWithText:NSLocalizedString(@"Full faith and credit shall be given in each state to the public acts, records, and judicial proceedings of every other state. And the Congress may by general laws prescribe the manner in which such acts, records, and proceedings shall be proved, and the effect thereof.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The citizens of each state shall be entitled to all privileges and immunities of citizens in the several states.\n\n"
                                                                          @"A person charged in any state with treason, felony, or other crime, who shall flee from justice, and be found in another state, shall on demand of the executive authority of the state from which he fled, be delivered up, to be removed to the state having jurisdiction of the crime.\n\n"
                                                                          @"No person held to service or labor in one state, under the laws thereof, escaping into another, shall, in consequence of any law or regulation therein, be discharged from such service or labor, but shall be delivered up on claim of the party to whom such service or labor may be due.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"New states may be admitted by the Congress into this union; but no new states shall be formed or erected within the jurisdiction of any other state; nor any state be formed by the junction of two or more states, or parts of states, without the consent of the legislatures of the states concerned as well as of the Congress.\n\n"
                                                                          @"The Congress shall have power to dispose of and make all needful rules and regulations respecting the territory or other property belonging to the United States; and nothing in this Constitution shall be so construed as to prejudice any claims of the United States, or of any particular state.", nil)],
                               [Section sectionWithText:NSLocalizedString(@"The United States shall guarantee to every state in this union a republican form of government, and shall protect each of them against invasion; and on application of the legislature, or of the executive (when the legislature cannot be convened) against domestic violence.", nil)],
                               nil]];
    
    Article* article5 =
    [Article articleWithTitle:NSLocalizedString(@"The Amendment Process", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_Five_of_the_United_States_Constitution"
                      section:[Section sectionWithText:NSLocalizedString(@"The Congress, whenever two thirds of both houses shall deem it necessary, shall propose amendments to this Constitution, or, on the application of the legislatures of two thirds of the several states, shall call a convention for proposing amendments, which, in either case, shall be valid to all intents and purposes, as part of this Constitution, when ratified by the legislatures of three fourths of the several states, or by conventions in three fourths thereof, as the one or the other mode of ratification may be proposed by the Congress; provided that no amendment which may be made prior to the year one thousand eight hundred and eight shall in any manner affect the first and fourth clauses in the ninth section of the first article; and that no state, without its consent, shall be deprived of its equal suffrage in the Senate.", nil)]];
    
    Article* article6 =
    [Article articleWithTitle:NSLocalizedString(@"Legal Status of the Constitution", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_Six_of_the_United_States_Constitution"
                      section:[Section sectionWithText:NSLocalizedString(@"All debts contracted and engagements entered into, before the adoption of this Constitution, shall be as valid against the United States under this Constitution, as under the Confederation.\n\n"
                                                                         @"This Constitution, and the laws of the United States which shall be made in pursuance thereof; and all treaties made, or which shall be made, under the authority of the United States, shall be the supreme law of the land; and the judges in every state shall be bound thereby, anything in the Constitution or laws of any State to the contrary notwithstanding.\n\n"
                                                                         @"The Senators and Representatives before mentioned, and the members of the several state legislatures, and all executive and judicial officers, both of the United States and of the several states, shall be bound by oath or affirmation, to support this Constitution; but no religious test shall ever be required as a qualification to any office or public trust under the United States.", nil)]];
    
    Article* article7 =
    [Article articleWithTitle:NSLocalizedString(@"Ratification", nil)
                         link:@"http://en.wikipedia.org/wiki/Article_Seven_of_the_United_States_Constitution"
                      section:[Section sectionWithText:NSLocalizedString(@"The ratification of the conventions of nine states, shall be sufficient for the establishment of this Constitution between the states so ratifying the same.", nil)]];
    
    Amendment* amendment1 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Religion, Speech, Press", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/First_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the government for a redress of grievances.", nil)];
    Amendment* amendment2 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Right to Bear Arms", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Second_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"A well regulated militia, being necessary to the security of a free state, the right of the people to keep and bear arms, shall not be infringed.", nil)];
    Amendment* amendment3 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Quartering of Troops", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Third_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"No soldier shall, in time of peace be quartered in any house, without the consent of the owner, nor in time of war, but in a manner to be prescribed by law.", nil)];
    Amendment* amendment4 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Search and Seizure", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Fourth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The right of the people to be secure in their persons, houses, papers, and effects, against unreasonable searches and seizures, shall not be violated, and no warrants shall issue, but upon probable cause, supported by oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized.", nil)];
    Amendment* amendment5 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Due Process", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Fifth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"No person shall be held to answer for a capital, or otherwise infamous crime, unless on a presentment or indictment of a grand jury, except in cases arising in the land or naval forces, or in the militia, when in actual service in time of war or public danger; nor shall any person be subject for the same offense to be twice put in jeopardy of life or limb; nor shall be compelled in any criminal case to be a witness against himself, nor be deprived of life, liberty, or property, without due process of law; nor shall private property be taken for public use, without just compensation.", nil)];
    Amendment* amendment6 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Right to Counsel", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Sixth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"In all criminal prosecutions, the accused shall enjoy the right to a speedy and public trial, by an impartial jury of the state and district wherein the crime shall have been committed, which district shall have been previously ascertained by law, and to be informed of the nature and cause of the accusation; to be confronted with the witnesses against him; to have compulsory process for obtaining witnesses in his favor, and to have the assistance of counsel for his defense.", nil)];
    Amendment* amendment7 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Jury Trial", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Seventh_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"In suits at common law, where the value in controversy shall exceed twenty dollars, the right of trial by jury shall be preserved, and no fact tried by a jury, shall be otherwise reexamined in any court of the United States, than according to the rules of the common law.", nil)];
    Amendment* amendment8 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Cruel and Unusual Punishment", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Eighth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"Excessive bail shall not be required, nor excessive fines imposed, nor cruel and unusual punishments inflicted.", nil)];
    Amendment* amendment9 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Non-Enumerated Rights", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Ninth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The enumeration in the Constitution, of certain rights, shall not be construed to deny or disparage others retained by the people.", nil)];
    Amendment* amendment10 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"States Rights", nil)
                                year:1791
                                link:@"http://en.wikipedia.org/wiki/Tenth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The powers not delegated to the United States by the Constitution, nor prohibited by it to the states, are reserved to the states respectively, or to the people.", nil)];
    Amendment* amendment11 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Suits Against a State", nil)
                                year:1795
                                link:@"http://en.wikipedia.org/wiki/Eleventh_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The judicial power of the United States shall not be construed to extend to any suit in law or equity, commenced or prosecuted against one of the United States by citizens of another state, or by citizens or subjects of any foreign state.", nil)];
    Amendment* amendment12 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"President and VP Election", nil)
                                year:1804
                                link:@"http://en.wikipedia.org/wiki/Twelfth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The electors shall meet in their respective states and vote by ballot for President and Vice-President, one of whom, at least, shall not be an inhabitant of the same state with themselves; they shall name in their ballots the person voted for as President, and in distinct ballots the person voted for as Vice-President, and they shall make distinct lists of all persons voted for as President, and of all persons voted for as Vice-President, and of the number of votes for each, which lists they shall sign and certify, and transmit sealed to the seat of the government of the United States, directed to the President of the Senate;--The President of the Senate shall, in the presence of the Senate and House of Representatives, open all the certificates and the votes shall then be counted;--the person having the greatest number of votes for President, shall be the President, if such number be a majority of the whole number of electors appointed; and if no person have such majority, then from the persons having the highest numbers not exceeding three on the list of those voted for as President, the House of Representatives shall choose immediately, by ballot, the President. But in choosing the President, the votes shall be taken by states, the representation from each state having one vote; a quorum for this purpose shall consist of a member or members from two-thirds of the states, and a majority of all the states shall be necessary to a choice. And if the House of Representatives shall not choose a President whenever the right of choice shall devolve upon them, before the fourth day of March next following, then the Vice-President shall act as President, as in the case of the death or other constitutional disability of the President. The person having the greatest number of votes as Vice-President, shall be the Vice-President, if such number be a majority of the whole number of electors appointed, and if no person have a majority, then from the two highest numbers on the list, the Senate shall choose the Vice-President; a quorum for the purpose shall consist of two-thirds of the whole number of Senators, and a majority of the whole number shall be necessary to a choice. But no person constitutionally ineligible to the office of President shall be eligible to that of Vice-President of the United States.", nil)];
    Amendment* amendment13 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Abolition of Slavery", nil)
                                year:1865
                                link:@"http://en.wikipedia.org/wiki/Thirteenth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"Neither slavery nor involuntary servitude, except as a punishment for crime whereof the party shall have been duly convicted, shall exist within the United States, or any place subject to their jurisdiction.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"Congress shall have power to enforce this article by appropriate legislation.", nil)], nil]];
    Amendment* amendment14 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Equal Protection", nil)
                                year:1868
                                link:@"http://en.wikipedia.org/wiki/Fourteenth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"All persons born or naturalized in the United States, and subject to the jurisdiction thereof, are citizens of the United States and of the state wherein they reside. No state shall make or enforce any law which shall abridge the privileges or immunities of citizens of the United States; nor shall any state deprive any person of life, liberty, or property, without due process of law; nor deny to any person within its jurisdiction the equal protection of the laws.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"Representatives shall be apportioned among the several states according to their respective numbers, counting the whole number of persons in each state, excluding Indians not taxed. But when the right to vote at any election for the choice of electors for President and Vice President of the United States, Representatives in Congress, the executive and judicial officers of a state, or the members of the legislature thereof, is denied to any of the male inhabitants of such state, being twenty-one years of age, and citizens of the United States, or in any way abridged, except for participation in rebellion, or other crime, the basis of representation therein shall be reduced in the proportion which the number of such male citizens shall bear to the whole number of male citizens twenty-one years of age in such state.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"No person shall be a Senator or Representative in Congress, or elector of President and Vice President, or hold any office, civil or military, under the United States, or under any state, who, having previously taken an oath, as a member of Congress, or as an officer of the United States, or as a member of any state legislature, or as an executive or judicial officer of any state, to support the Constitution of the United States, shall have engaged in insurrection or rebellion against the same, or given aid or comfort to the enemies thereof. But Congress may by a vote of two-thirds of each House, remove such disability.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The validity of the public debt of the United States, authorized by law, including debts incurred for payment of pensions and bounties for services in suppressing insurrection or rebellion, shall not be questioned. But neither the United States nor any state shall assume or pay any debt or obligation incurred in aid of insurrection or rebellion against the United States, or any claim for the loss or emancipation of any slave; but all such debts, obligations and claims shall be held illegal and void.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress shall have power to enforce, by appropriate legislation, the provisions of this article.", nil)], nil]];
    Amendment* amendment15 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Race Rights", nil)
                                year:1870
                                link:@"http://en.wikipedia.org/wiki/Fifteenth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"The right of citizens of the United States to vote shall not be denied or abridged by the United States or by any state on account of race, color, or previous condition of servitude.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress shall have power to enforce this article by appropriate legislation.", nil)], nil]];
    Amendment* amendment16 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Income Tax", nil)
                                year:1913
                                link:@"http://en.wikipedia.org/wiki/Sixteenth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The Congress shall have power to lay and collect taxes on incomes, from whatever source derived, without apportionment among the several states, and without regard to any census or enumeration.", nil)];
    Amendment* amendment17 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Election of Senators", nil)
                                year:1913
                                link:@"http://en.wikipedia.org/wiki/Seventeenth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The Senate of the United States shall be composed of two Senators from each state, elected by the people thereof, for six years; and each Senator shall have one vote. The electors in each state shall have the qualifications requisite for electors of the most numerous branch of the state legislatures.\n\n"
                                                       @"When vacancies happen in the representation of any state in the Senate, the executive authority of such state shall issue writs of election to fill such vacancies: Provided, that the legislature of any state may empower the executive thereof to make temporary appointments until the people fill the vacancies by election as the legislature may direct.\n\n"
                                                       @"This amendment shall not be so construed as to affect the election or term of any Senator chosen before it becomes valid as part of the Constitution.", nil)];
    Amendment* amendment18 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Prohibition", nil)
                                year:1919
                                link:@"http://en.wikipedia.org/wiki/Eighteenth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"After one year from the ratification of this article the manufacture, sale, or transportation of intoxicating liquors within, the importation thereof into, or the exportation thereof from the United States and all territory subject to the jurisdiction thereof for beverage purposes is hereby prohibited.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress and the several states shall have concurrent power to enforce this article by appropriate legislation.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"This article shall be inoperative unless it shall have been ratified as an amendment to the Constitution by the legislatures of the several states, as provided in the Constitution, within seven years from the date of the submission hereof to the states by the Congress.", nil)], nil]];
    Amendment* amendment19 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Women's Rights", nil)
                                year:1920
                                link:@"http://en.wikipedia.org/wiki/Nineteenth_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"The right of citizens of the United States to vote shall not be denied or abridged by the United States or by any state on account of sex.\n\n"
                                                       @"Congress shall have power to enforce this article by appropriate legislation.", nil)];
    Amendment* amendment20 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Presidential Succession", nil)
                                year:1933
                                link:@"http://en.wikipedia.org/wiki/Twentieth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"The terms of the President and Vice President shall end at noon on the 20th day of January, and the terms of Senators and Representatives at noon on the 3d day of January, of the years in which such terms would have ended if this article had not been ratified; and the terms of their successors shall then begin.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress shall assemble at least once in every year, and such meeting shall begin at noon on the 3d day of January, unless they shall by law appoint a different day.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"If, at the time fixed for the beginning of the term of the President, the President elect shall have died, the Vice President elect shall become President. If a President shall not have been chosen before the time fixed for the beginning of his term, or if the President elect shall have failed to qualify, then the Vice President elect shall act as President until a President shall have qualified; and the Congress may by law provide for the case wherein neither a President elect nor a Vice President elect shall have qualified, declaring who shall then act as President, or the manner in which one who is to act shall be selected, and such person shall act accordingly until a President or Vice President shall have qualified.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress may by law provide for the case of the death of any of the persons from whom the House of Representatives may choose a President whenever the right of choice shall have devolved upon them, and for the case of the death of any of the persons from whom the Senate may choose a Vice President whenever the right of choice shall have devolved upon them.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"Sections 1 and 2 shall take effect on the 15th day of October following the ratification of this article.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"This article shall be inoperative unless it shall have been ratified as an amendment to the Constitution by the legislatures of three-fourths of the several states within seven years from the date of its submission.", nil)], nil]];
    Amendment* amendment21 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Repeal of Prohibition", nil)
                                year:1933
                                link:@"http://en.wikipedia.org/wiki/Twenty-first_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"The eighteenth article of amendment to the Constitution of the United States is hereby repealed.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The transportation or importation into any state, territory, or possession of the United States for delivery or use therein of intoxicating liquors, in violation of the laws thereof, is hereby prohibited.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"This article shall be inoperative unless it shall have been ratified as an amendment to the Constitution by conventions in the several states, as provided in the Constitution, within seven years from the date of the submission hereof to the states by the Congress.", nil)], nil]];
    Amendment* amendment22 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Presidential Term Limit", nil)
                                year:1951
                                link:@"http://en.wikipedia.org/wiki/Twenty-second_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"No person shall be elected to the office of the President more than twice, and no person who has held the office of President, or acted as President, for more than two years of a term to which some other person was elected President shall be elected to the office of the President more than once. But this article shall not apply to any person holding the office of President when this article was proposed by the Congress, and shall not prevent any person who may be holding the office of President, or acting as President, during the term within which this article becomes operative from holding the office of President or acting as President during the remainder of such term.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"This article shall be inoperative unless it shall have been ratified as an amendment to the Constitution by the legislatures of three-fourths of the several states within seven years from the date of its submission to the states by the Congress.", nil)], nil]];
    Amendment* amendment23 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"D.C. Vote", nil)
                                year:1961
                                link:@"http://en.wikipedia.org/wiki/Twenty-third_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"The District constituting the seat of government of the United States shall appoint in such manner as the Congress may direct:\n\n"
                                                                                 @"A number of electors of President and Vice President equal to the whole number of Senators and Representatives in Congress to which the District would be entitled if it were a state, but in no event more than the least populous state; they shall be in addition to those appointed by the states, but they shall be considered, for the purposes of the election of President and Vice President, to be electors appointed by a state; and they shall meet in the District and perform such duties as provided by the twelfth article of amendment.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress shall have power to enforce this article by appropriate legislation.", nil)], nil]];
    
    Amendment* amendment24 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Poll Tax", nil)
                                year:1964
                                link:@"http://en.wikipedia.org/wiki/Twenty-fourth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"The right of citizens of the United States to vote in any primary or other election for President or Vice President, for electors for President or Vice President, or for Senator or Representative in Congress, shall not be denied or abridged by the United States or any state by reason of failure to pay any poll tax or other tax.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress shall have power to enforce this article by appropriate legislation.", nil)], nil]];
    Amendment* amendment25 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Presidential Succession", nil)
                                year:1967
                                link:@"http://en.wikipedia.org/wiki/Twenty-fifth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"In case of the removal of the President from office or of his death or resignation, the Vice President shall become President.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"Whenever there is a vacancy in the office of the Vice President, the President shall nominate a Vice President who shall take office upon confirmation by a majority vote of both Houses of Congress.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"Whenever the President transmits to the President pro tempore of the Senate and the Speaker of the House of Representatives his written declaration that he is unable to discharge the powers and duties of his office, and until he transmits to them a written declaration to the contrary, such powers and duties shall be discharged by the Vice President as Acting President.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"Whenever the Vice President and a majority of either the principal officers of the executive departments or of such other body as Congress may by law provide, transmit to the President pro tempore of the Senate and the Speaker of the House of Representatives their written declaration that the President is unable to discharge the powers and duties of his office, the Vice President shall immediately assume the powers and duties of the office as Acting President.\n\n"
                                                                                 @"Thereafter, when the President transmits to the President pro tempore of the Senate and the Speaker of the House of Representatives his written declaration that no inability exists, he shall resume the powers and duties of his office unless the Vice President and a majority of either the principal officers of the executive department or of such other body as Congress may by law provide, transmit within four days to the President pro tempore of the Senate and the Speaker of the House of Representatives their written declaration that the President is unable to discharge the powers and duties of his office. Thereupon Congress shall decide the issue, assembling within forty-eight hours for that purpose if not in session. If the Congress, within twenty-one days after receipt of the latter written declaration, or, if Congress is not in session, within twenty-one days after Congress is required to assemble, determines by two-thirds vote of both Houses that the President is unable to discharge the powers and duties of his office, the Vice President shall continue to discharge the same as Acting President; otherwise, the President shall resume the powers and duties of his office.", nil)], nil]];
    Amendment* amendment26 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Vote at Age 18", nil)
                                year:1971
                                link:@"http://en.wikipedia.org/wiki/Twenty-sixth_Amendment_to_the_United_States_Constitution"
                            sections:[NSArray arrayWithObjects:
                                      [Section sectionWithText:NSLocalizedString(@"The right of citizens of the United States, who are 18 years of age or older, to vote, shall not be denied or abridged by the United States or any state on account of age.", nil)],
                                      [Section sectionWithText:NSLocalizedString(@"The Congress shall have the power to enforce this article by appropriate legislation.", nil)], nil]];
    Amendment* amendment27 =
    [Amendment amendmentWithSynopsis:NSLocalizedString(@"Congressional Compensation", nil)
                                year:1992
                                link:@"http://en.wikipedia.org/wiki/Twenty-seventh_Amendment_to_the_United_States_Constitution"
                                text:NSLocalizedString(@"No law, varying the compensation for the services of the Senators and Representatives, shall take effect, until an election of Representatives shall have intervened.", nil)];
    
    NSArray* articles = [NSArray arrayWithObjects:article1, article2, article3, article4, article5, article6, article7, nil];
    
    NSArray* amendments =
    [NSArray arrayWithObjects:amendment1, amendment2, amendment3, amendment4, amendment5,
     amendment6, amendment7, amendment8, amendment9, amendment10,
     amendment11, amendment12, amendment13, amendment14, amendment15,
     amendment16, amendment17, amendment18, amendment19, amendment20,
     amendment21, amendment22, amendment23, amendment24, amendment25,
     amendment26, amendment27, nil];
    
    MultiDictionary* signers = [MultiDictionary dictionary];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"George Washington", @"http://en.wikipedia.org/wiki/George_Washington"),
                         person(@"John Blair", @"http://en.wikipedia.org/wiki/John_Blair"),
                         person(@"James Madison Jr.", @"http://en.wikipedia.org/wiki/James_Madison"), nil] forKey:@"Virginia"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Langdon", @"http://en.wikipedia.org/wiki/John_Langdon"),
                         person(@"Nicholas Gilman", @"http://en.wikipedia.org/wiki/Nicholas_Gilman"), nil] forKey:@"New Hampshire"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Nathaniel Gorham", @"http://en.wikipedia.org/wiki/Nathaniel_Gorham"),
                         person(@"Rufus King", @"http://en.wikipedia.org/wiki/Rufus_King"), nil] forKey:@"Massachusetts"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Samuel Johnson", @"http://en.wikipedia.org/wiki/William_Samuel_Johnson"), 
                         person(@"Roger Sherman", @"http://en.wikipedia.org/wiki/Roger_Sherman"), nil] forKey:@"Connecticut"];
    [signers addObject:person(@"Alexander Hamilton", @"http://en.wikipedia.org/wiki/Alexander_Hamilton") forKey:@"New York"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Livingston", @"http://en.wikipedia.org/wiki/William_Livingston"),
                         person(@"David Brearly", @"http://en.wikipedia.org/wiki/David_Brearly"),
                         person(@"William Paterson", @"http://en.wikipedia.org/wiki/William_Paterson_(judge)"),
                         person(@"Jonathan Dayton", @"http://en.wikipedia.org/wiki/Jonathan_Dayton"), nil] forKey:@"New Jersey"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Benjamin Franklin", @"http://en.wikipedia.org/wiki/Benjamin_franklin"),
                         person(@"Thomas Mifflin", @"http://en.wikipedia.org/wiki/Thomas_Mifflin"), 
                         person(@"Robert Morris", @"http://en.wikipedia.org/wiki/Robert_Morris_(financier)"),
                         person(@"George Clymer", @"http://en.wikipedia.org/wiki/George_Clymer"),
                         person(@"Thomas FitzSimons", @"http://en.wikipedia.org/wiki/Thomas_Fitzsimons"),
                         person(@"Jared Ingersoll", @"http://en.wikipedia.org/wiki/Jared_Ingersoll"),
                         person(@"James Wilson", @"http://en.wikipedia.org/wiki/James_Wilson"),
                         person(@"Gouverneur Morris", @"http://en.wikipedia.org/wiki/Gouverneur_Morris"), nil] forKey:@"Pennsylvania"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"George Read", @"http://en.wikipedia.org/wiki/George_Read_(signer)"),
                         person(@"Gunning Bedford Jr.", @"http://en.wikipedia.org/wiki/Gunning_Bedford,_Jr."),
                         person(@"John Dickinson", @"http://en.wikipedia.org/wiki/John_Dickinson_(delegate)"),
                         person(@"Richard Bassett", @"http://en.wikipedia.org/wiki/Richard_Bassett"),
                         person(@"Jacob Broom", @"http://en.wikipedia.org/wiki/Jacob_Broom"), nil] forKey:@"Delaware"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"James McHenry", @"http://en.wikipedia.org/wiki/James_McHenry"),
                         person(@"Daniel of St. Thomas Jenifer", @"http://en.wikipedia.org/wiki/Daniel_of_St._Thomas_Jenifer"),
                         person(@"Daniel Carroll", @"http://en.wikipedia.org/wiki/Daniel_Carroll"), nil] forKey:@"Maryland"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Blount", @"http://en.wikipedia.org/wiki/William_Blount"),
                         person(@"Richard Dobbs Spaight", @"http://en.wikipedia.org/wiki/Richard_Dobbs_Spaight"),
                         person(@"Hugh Williamson", @"http://en.wikipedia.org/wiki/Hugh_Williamson"), nil] forKey:@"North Carolina"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Rutledge", @"http://en.wikipedia.org/wiki/John_Rutledge"),
                         person(@"Charles Cotesworth Pinckney", @"http://en.wikipedia.org/wiki/Charles_Cotesworth_Pinckney"),
                         person(@"Charles Pinckney", @"http://en.wikipedia.org/wiki/Charles_Pinckney_(governor)"),
                         person(@"Pierce Butler", @"http://en.wikipedia.org/wiki/Pierce_Butler"), nil] forKey:@"South Carolina"];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Few", @"http://en.wikipedia.org/wiki/William_Few"),
                         person(@"Abraham Baldwin", @"http://en.wikipedia.org/wiki/Abraham_Baldwin"), nil] forKey:@"Georgia"];
    
    return [Constitution constitutionWithCountry:country
                                        preamble:NSLocalizedString(@"We the people of the United States, in order to form a more perfect union, establish justice, insure domestic tranquility, provide for the common defense, promote the general welfare, and secure the blessings of liberty to ourselves and our posterity, do ordain and establish this Constitution for the United States of America.", nil)
                                        articles:articles
                                      amendments:amendments
                                      conclusion:@""
                                         signers:signers];
}


+ (void) setupConstitutions {
    unitedStatesConstitution = [[self setupUnitedStatesConstitution] retain];
}


+ (void) setupDeclarationOfIndependence {
    NSString* text =
    @"When in the Course of human events it becomes necessary for one people to dissolve the political bands which have connected them with another and to assume among the powers of the earth, the separate and equal station to which the Laws of Nature and of Nature's God entitle them, a decent respect to the opinions of mankind requires that they should declare the causes which impel them to the separation.\n\n"
    @"We hold these truths to be self-evident, that all men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty and the pursuit of Happiness. — That to secure these rights, Governments are instituted among Men, deriving their just powers from the consent of the governed, — That whenever any Form of Government becomes destructive of these ends, it is the Right of the People to alter or to abolish it, and to institute new Government, laying its foundation on such principles and organizing its powers in such form, as to them shall seem most likely to effect their Safety and Happiness. Prudence, indeed, will dictate that Governments long established should not be changed for light and transient causes; and accordingly all experience hath shewn that mankind are more disposed to suffer, while evils are sufferable than to right themselves by abolishing the forms to which they are accustomed. But when a long train of abuses and usurpations, pursuing invariably the same Object evinces a design to reduce them under absolute Despotism, it is their right, it is their duty, to throw off such Government, and to provide new Guards for their future security. — Such has been the patient sufferance of these Colonies; and such is now the necessity which constrains them to alter their former Systems of Government. The history of the present King of Great Britain is a history of repeated injuries and usurpations, all having in direct object the establishment of an absolute Tyranny over these States. To prove this, let Facts be submitted to a candid world.\n\n"
    @"He has refused his Assent to Laws, the most wholesome and necessary for the public good.\n\n"
    @"He has forbidden his Governors to pass Laws of immediate and pressing importance, unless suspended in their operation till his Assent should be obtained; and when so suspended, he has utterly neglected to attend to them.\n\n"
    @"He has refused to pass other Laws for the accommodation of large districts of people, unless those people would relinquish the right of Representation in the Legislature, a right inestimable to them and formidable to tyrants only.\n\n"
    @"He has called together legislative bodies at places unusual, uncomfortable, and distant from the depository of their Public Records, for the sole purpose of fatiguing them into compliance with his measures.\n\n"
    @"He has dissolved Representative Houses repeatedly, for opposing with manly firmness his invasions on the rights of the people.\n\n"
    @"He has refused for a long time, after such dissolutions, to cause others to be elected, whereby the Legislative Powers, incapable of Annihilation, have returned to the People at large for their exercise; the State remaining in the mean time exposed to all the dangers of invasion from without, and convulsions within.\n\n"
    @"He has endeavoured to prevent the population of these States; for that purpose obstructing the Laws for Naturalization of Foreigners; refusing to pass others to encourage their migrations hither, and raising the conditions of new Appropriations of Lands.\n\n"
    @"He has obstructed the Administration of Justice by refusing his Assent to Laws for establishing Judiciary Powers.\n\n"
    @"He has made Judges dependent on his Will alone for the tenure of their offices, and the amount and payment of their salaries.\n\n"
    @"He has erected a multitude of New Offices, and sent hither swarms of Officers to harass our people and eat out their substance.\n\n"
    @"He has kept among us, in times of peace, Standing Armies without the Consent of our legislatures.\n\n"
    @"He has affected to render the Military independent of and superior to the Civil Power.\n\n"
    @"He has combined with others to subject us to a jurisdiction foreign to our constitution, and unacknowledged by our laws; giving his Assent to their Acts of pretended Legislation:\n\n"
    @"For quartering large bodies of armed troops among us:\n\n"
    @"For protecting them, by a mock Trial from punishment for any Murders which they should commit on the Inhabitants of these States:\n\n"
    @"For cutting off our Trade with all parts of the world:\n\n"
    @"For imposing Taxes on us without our Consent:\n\n"
    @"For depriving us in many cases, of the benefit of Trial by Jury:\n\n"
    @"For transporting us beyond Seas to be tried for pretended offences:\n\n"
    @"For abolishing the free System of English Laws in a neighbouring Province, establishing therein an Arbitrary government, and enlarging its Boundaries so as to render it at once an example and fit instrument for introducing the same absolute rule into these Colonies\n\n"
    @"For taking away our Charters, abolishing our most valuable Laws and altering fundamentally the Forms of our Governments:\n\n"
    @"For suspending our own Legislatures, and declaring themselves invested with power to legislate for us in all cases whatsoever.\n\n"
    @"He has abdicated Government here, by declaring us out of his Protection and waging War against us.\n\n"
    @"He has plundered our seas, ravaged our coasts, burnt our towns, and destroyed the lives of our people.\n\n"
    @"He is at this time transporting large Armies of foreign Mercenaries to compleat the works of death, desolation, and tyranny, already begun with circumstances of Cruelty & Perfidy scarcely paralleled in the most barbarous ages, and totally unworthy the Head of a civilized nation.\n\n"
    @"He has constrained our fellow Citizens taken Captive on the high Seas to bear Arms against their Country, to become the executioners of their friends and Brethren, or to fall themselves by their Hands.\n\n"
    @"He has excited domestic insurrections amongst us, and has endeavoured to bring on the inhabitants of our frontiers, the merciless Indian Savages whose known rule of warfare, is an undistinguished destruction of all ages, sexes and conditions.\n\n"
    @"In every stage of these Oppressions We have Petitioned for Redress in the most humble terms: Our repeated Petitions have been answered only by repeated injury. A Prince, whose character is thus marked by every act which may define a Tyrant, is unfit to be the ruler of a free people.\n\n"
    @"Nor have We been wanting in attentions to our British brethren. We have warned them from time to time of attempts by their legislature to extend an unwarrantable jurisdiction over us. We have reminded them of the circumstances of our emigration and settlement here. We have appealed to their native justice and magnanimity, and we have conjured them by the ties of our common kindred to disavow these usurpations, which would inevitably interrupt our connections and correspondence. They too have been deaf to the voice of justice and of consanguinity. We must, therefore, acquiesce in the necessity, which denounces our Separation, and hold them, as we hold the rest of mankind, Enemies in War, in Peace Friends.\n\n"
    @"We, therefore, the Representatives of the united States of America, in General Congress, Assembled, appealing to the Supreme Judge of the world for the rectitude of our intentions, do, in the Name, and by Authority of the good People of these Colonies, solemnly publish and declare, That these united Colonies are, and of Right ought to be Free and Independent States, that they are Absolved from all Allegiance to the British Crown, and that all political connection between them and the State of Great Britain, is and ought to be totally dissolved; and that as Free and Independent States, they have full Power to levy War, conclude Peace, contract Alliances, establish Commerce, and to do all other Acts and Things which Independent States may of right do. — And for the support of this Declaration, with a firm reliance on the protection of Divine Providence, we mutually pledge to each other our Lives, our Fortunes, and our sacred Honor.\n\n"
    @"— John Hancock";
    
    MultiDictionary* signers = [MultiDictionary dictionary];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Josiah Bartlett", @"http://en.wikipedia.org/wiki/Josiah_Bartlett"),
                         person(@"William Whipple", @"http://en.wikipedia.org/wiki/William_Whipple"),
                         person(@"Matthew Thornton", @"http://en.wikipedia.org/wiki/Matthew_Thornton"), nil] forKey:@"New Hampshire"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Hancock", @"http://en.wikipedia.org/wiki/John_Hancock"),
                         person(@"Samuel Adams", @"http://en.wikipedia.org/wiki/Samuel_adams"),
                         person(@"John Adams", @"http://en.wikipedia.org/wiki/John_Adams"),
                         person(@"Robert Treat Paine", @"http://en.wikipedia.org/wiki/Robert_Treat_Paine"),
                         person(@"Elbridge Gerry", @"http://en.wikipedia.org/wiki/Elbridge_Gerry"), nil] forKey:@"Massachusetts"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Stephen Hopkins", @"http://en.wikipedia.org/wiki/Stephen_Hopkins_(politician)"),
                         person(@"William Ellery", @"http://en.wikipedia.org/wiki/William_Ellery"), nil] forKey:@"Rhode Island"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Roger Sherman", @"http://en.wikipedia.org/wiki/Roger_Sherman"),
                         person(@"Samuel Huntington", @"http://en.wikipedia.org/wiki/Samuel_Huntington_(statesman)"),
                         person(@"William Williams", @"http://en.wikipedia.org/wiki/William_Williams_(signer)"),
                         person(@"Oliver Wolcott", @"http://en.wikipedia.org/wiki/Oliver_Wolcott"), nil] forKey:@"Connecticut"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Floyd", @"http://en.wikipedia.org/wiki/William_Floyd"),
                         person(@"Philip Livingston", @"http://en.wikipedia.org/wiki/Philip_Livingston"),
                         person(@"Francis Lewis", @"http://en.wikipedia.org/wiki/Francis_Lewis"),
                         person(@"Lewis Morris", @"http://en.wikipedia.org/wiki/Lewis_Morris"), nil] forKey:@"New York"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Richard Stockton", @"http://en.wikipedia.org/wiki/Richard_Stockton_(1730-1781)"),
                         person(@"John Witherspoon", @"http://en.wikipedia.org/wiki/John_Witherspoon"),
                         person(@"Francis Hopkinson", @"http://en.wikipedia.org/wiki/Francis_Hopkinson"),
                         person(@"John Hart", @"http://en.wikipedia.org/wiki/John_Hart"),
                         person(@"Abraham Clark", @"http://en.wikipedia.org/wiki/Abraham_Clark"), nil] forKey:@"New Jersey"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Robert Morris", @"http://en.wikipedia.org/wiki/Robert_Morris_(financier)"),
                         person(@"Benjamin Rush", @"http://en.wikipedia.org/wiki/Benjamin_Rush"),
                         person(@"Benjamin Franklin", @"http://en.wikipedia.org/wiki/Benjamin_Franklin"),
                         person(@"John Morton", @"http://en.wikipedia.org/wiki/John_Morton_(politician)"),
                         person(@"George Clymer", @"http://en.wikipedia.org/wiki/George_Clymer"),
                         person(@"James Smith", @"http://en.wikipedia.org/wiki/James_Smith_(political_figure)"),
                         person(@"George Taylor", @"http://en.wikipedia.org/wiki/George_Taylor_(delegate)"),
                         person(@"James Wilson", @"http://en.wikipedia.org/wiki/James_Wilson"),
                         person(@"George Ross", @"http://en.wikipedia.org/wiki/George_Ross_(delegate)"), nil] forKey:@"Pennsylvania"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Caesar Rodney", @"http://en.wikipedia.org/wiki/Caesar_Rodney"),
                         person(@"George Read", @"http://en.wikipedia.org/wiki/George_Read_(signer)"),
                         person(@"Thomas McKean", @"http://en.wikipedia.org/wiki/Thomas_McKean"), nil] forKey:@"Delaware"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Samuel Chase", @"http://en.wikipedia.org/wiki/Samuel_Chase"),
                         person(@"William Paca", @"http://en.wikipedia.org/wiki/William_Paca"),
                         person(@"Thomas Stone", @"http://en.wikipedia.org/wiki/Thomas_Stone"),
                         person(@"Charles Carroll of Carrollton", @"http://en.wikipedia.org/wiki/Charles_Carroll_of_Carrollton"), nil] forKey:@"Maryland"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"George Wythe", @"http://en.wikipedia.org/wiki/George_Wythe"),
                         person(@"Richard Henry Lee", @"http://en.wikipedia.org/wiki/Richard_Henry_Lee"),
                         person(@"Thomas Jefferson", @"http://en.wikipedia.org/wiki/Thomas_Jefferson"),
                         person(@"Benjamin Harrison", @"http://en.wikipedia.org/wiki/Benjamin_Harrison"),
                         person(@"Thomas Nelson Jr.", @"http://en.wikipedia.org/wiki/Thomas_Nelson,_Jr."),
                         person(@"Francis Lightfoot Lee", @"http://en.wikipedia.org/wiki/Francis_Lightfoot_Lee"),
                         person(@"Carter Braxton", @"http://en.wikipedia.org/wiki/Carter_Braxton"), nil] forKey:@"Virginia"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Hooper", @"http://en.wikipedia.org/wiki/William_Hooper"),
                         person(@"Joseph Hewes", @"http://en.wikipedia.org/wiki/Joseph_Hewes"),
                         person(@"John Penn", @"http://en.wikipedia.org/wiki/John_Penn_(delegate)"), nil] forKey:@"North Carolina"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Edward Rutledge", @"http://en.wikipedia.org/wiki/Edward_Rutledge"),
                         person(@"Thomas Heyward Jr.", @"http://en.wikipedia.org/wiki/Thomas_Heyward"),
                         person(@"Thomas Lynch Jr.", @"http://en.wikipedia.org/wiki/Thomas_Lynch,_Jr."),
                         person(@"Arthur Middleton", @"http://en.wikipedia.org/wiki/Arthur_Middleton"), nil] forKey:@"South Carolina"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Button Gwinnett", @"http://en.wikipedia.org/wiki/Button_Gwinnett"),
                         person(@"Lyman Hall", @"http://en.wikipedia.org/wiki/Lyman_Hall"),
                         person(@"George Walton", @"http://en.wikipedia.org/wiki/George_Walton"), nil] forKey:@"Georgia"];
    
    NSDate* date = [NSDate dateWithNaturalLanguageString:@"July 4, 1776"];
    
    declarationOfIndependence = [[DeclarationOfIndependence declarationWithText:text signers:signers date:date] retain];
}


+ (void) setupArticlesOfConfederation {
    NSString* country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:@"US"];    
    
    NSString* preamble =
    NSLocalizedString(@"To all to whom these Presents shall come, we the undersigned Delegates of the States affixed to our Names send greeting.\n\n"
                      @"Articles of Confederation and perpetual Union between the States of New Hampshire, Massachusetts bay, Rhode Island and Providence Plantations, Connecticut, New York, New Jersey, Pennsylvania, Delaware, Maryland, Virginia, North Carolina, South Carolina and Georgia.", nil);
    
    NSArray* articles = 
    [NSArray arrayWithObjects:
     [Article articleWithTitle:@"Article I"
                       section:[Section sectionWithText:NSLocalizedString(@"The Stile of this Confederacy shall be 'The United States of America.'", nil)]],
     [Article articleWithTitle:@"Article II"
                       section:[Section sectionWithText:NSLocalizedString(@"Each state retains its sovereignty, freedom, and independence, and every power, jurisdiction, and right, which is not by this Confederation expressly delegated to the United States, in Congress assembled.", nil)]],
     [Article articleWithTitle:@"Article III"
                       section:[Section sectionWithText:NSLocalizedString(@"The said States hereby severally enter into a firm league of friendship with each other, for their common defense, the security of their liberties, and their mutual and general welfare, binding themselves to assist each other, against all force offered to, or attacks made upon them, or any of them, on account of religion, sovereignty, trade, or any other pretense whatever.", nil)]],
     [Article articleWithTitle:@"Article IV"
                       section:[Section sectionWithText:NSLocalizedString(@"The better to secure and perpetuate mutual friendship and intercourse among the people of the different States in this Union, the free inhabitants of each of these States, paupers, vagabonds, and fugitives from justice excepted, shall be entitled to all privileges and immunities of free citizens in the several States; and the people of each State shall free ingress and regress to and from any other State, and shall enjoy therein all the privileges of trade and commerce, subject to the same duties, impositions, and restrictions as the inhabitants thereof respectively, provided that such restrictions shall not extend so far as to prevent the removal of property imported into any State, to any other State, of which the owner is an inhabitant; provided also that no imposition, duties or restriction shall be laid by any State, on the property of the United States, or either of them.\n\n"
                                                                          @"If any person guilty of, or charged with, treason, felony, or other high misdemeanor in any State, shall flee from justice, and be found in any of the United States, he shall, upon demand of the Governor or executive power of the State from which he fled, be delivered up and removed to the State having jurisdiction of his offense.\n\n"
                                                                          @"Full faith and credit shall be given in each of these States to the records, acts, and judicial proceedings of the courts and magistrates of every other State.", nil)]],
     [Article articleWithTitle:@"Article V"
                       section:[Section sectionWithText:NSLocalizedString(@"For the most convenient management of the general interests of the United States, delegates shall be annually appointed in such manner as the legislatures of each State shall direct, to meet in Congress on the first Monday in November, in every year, with a power reserved to each State to recall its delegates, or any of them, at any time within the year, and to send others in their stead for the remainder of the year.\n\n"
                                                                          @"No State shall be represented in Congress by less than two, nor more than seven members; and no person shall be capable of being a delegate for more than three years in any term of six years; nor shall any person, being a delegate, be capable of holding any office under the United States, for which he, or another for his benefit, receives any salary, fees or emolument of any kind.\n\n"
                                                                          @"Each State shall maintain its own delegates in a meeting of the States, and while they act as members of the committee of the States.\n\n"
                                                                          @"In determining questions in the United States in Congress assembled, each State shall have one vote.\n\n"
                                                                          @"Freedom of speech and debate in Congress shall not be impeached or questioned in any court or place out of Congress, and the members of Congress shall be protected in their persons from arrests or imprisonments, during the time of their going to and from, and attendance on Congress, except for treason, felony, or breach of the peace.", nil)]],
     [Article articleWithTitle:@"Article VI"
                       section:[Section sectionWithText:NSLocalizedString(@"No State, without the consent of the United States in Congress assembled, shall send any embassy to, or receive any embassy from, or enter into any conference, agreement, alliance or treaty with any King, Prince or State; nor shall any person holding any office of profit or trust under the United States, or any of them, accept any present, emolument, office or title of any kind whatever from any King, Prince or foreign State; nor shall the United States in Congress assembled, or any of them, grant any title of nobility.\n\n"
                                                                          @"No two or more States shall enter into any treaty, confederation or alliance whatever between them, without the consent of the United States in Congress assembled, specifying accurately the purposes for which the same is to be entered into, and how long it shall continue.\n\n"
                                                                          @"No State shall lay any imposts or duties, which may interfere with any stipulations in treaties, entered into by the United States in Congress assembled, with any King, Prince or State, in pursuance of any treaties already proposed by Congress, to the courts of France and Spain.\n\n"
                                                                          @"No vessel of war shall be kept up in time of peace by any State, except such number only, as shall be deemed necessary by the United States in Congress assembled, for the defense of such State, or its trade; nor shall any body of forces be kept up by any State in time of peace, except such number only, as in the judgement of the United States in Congress assembled, shall be deemed requisite to garrison the forts necessary for the defense of such State; but every State shall always keep up a well-regulated and disciplined militia, sufficiently armed and accoutered, and shall provide and constantly have ready for use, in public stores, a due number of filed pieces and tents, and a proper quantity of arms, ammunition and camp equipage.\n\n"
                                                                          @"No State shall engage in any war without the consent of the United States in Congress assembled, unless such State be actually invaded by enemies, or shall have received certain advice of a resolution being formed by some nation of Indians to invade such State, and the danger is so imminent as not to admit of a delay till the United States in Congress assembled can be consulted; nor shall any State grant commissions to any ships or vessels of war, nor letters of marque or reprisal, except it be after a declaration of war by the United States in Congress assembled, and then only against the Kingdom or State and the subjects thereof, against which war has been so declared, and under such regulations as shall be established by the United States in Congress assembled, unless such State be infested by pirates, in which case vessels of war may be fitted out for that occasion, and kept so long as the danger shall continue, or until the United States in Congress assembled shall determine otherwise.", nil)]],
     [Article articleWithTitle:@"Article VII"
                       section:[Section sectionWithText:NSLocalizedString(@"When land forces are raised by any State for the common defense, all officers of or under the rank of colonel, shall be appointed by the legislature of each State respectively, by whom such forces shall be raised, or in such manner as such State shall direct, and all vacancies shall be filled up by the State which first made the appointment.", nil)]],
     
     [Article articleWithTitle:@"Article VIII"
                       section:[Section sectionWithText:NSLocalizedString(@"All charges of war, and all other expenses that shall be incurred for the common defense or general welfare, and allowed by the United States in Congress assembled, shall be defrayed out of a common treasury, which shall be supplied by the several States in proportion to the value of all land within each State, granted or surveyed for any person, as such land and the buildings and improvements thereon shall be estimated according to such mode as the United States in Congress assembled, shall from time to time direct and appoint.\n\n"
                                                                          @"The taxes for paying that proportion shall be laid and levied by the authority and direction of the legislatures of the several States within the time agreed upon by the United States in Congress assembled.", nil)]],
     [Article articleWithTitle:@"Article IX"
                       section:[Section sectionWithText:NSLocalizedString(@"The United States in Congress assembled, shall have the sole and exclusive right and power of determining on peace and war, except in the cases mentioned in the sixth article — of sending and receiving ambassadors — entering into treaties and alliances, provided that no treaty of commerce shall be made whereby the legislative power of the respective States shall be restrained from imposing such imposts and duties on foreigners, as their own people are subjected to, or from prohibiting the exportation or importation of any species of goods or commodities whatsoever — of establishing rules for deciding in all cases, what captures on land or water shall be legal, and in what manner prizes taken by land or naval forces in the service of the United States shall be divided or appropriated — of granting letters of marque and reprisal in times of peace — appointing courts for the trial of piracies and felonies committed on the high seas and establishing courts for receiving and determining finally appeals in all cases of captures, provided that no member of Congress shall be appointed a judge of any of the said courts.\n\n"
                                                                          @"The United States in Congress assembled shall also be the last resort on appeal in all disputes and differences now subsisting or that hereafter may arise between two or more States concerning boundary, jurisdiction or any other causes whatever; which authority shall always be exercised in the manner following. Whenever the legislative or executive authority or lawful agent of any State in controversy with another shall present a petition to Congress stating the matter in question and praying for a hearing, notice thereof shall be given by order of Congress to the legislative or executive authority of the other State in controversy, and a day assigned for the appearance of the parties by their lawful agents, who shall then be directed to appoint by joint consent, commissioners or judges to constitute a court for hearing and determining the matter in question: but if they cannot agree, Congress shall name three persons out of each of the United States, and from the list of such persons each party shall alternately strike out one, the petitioners beginning, until the number shall be reduced to thirteen; and from that number not less than seven, nor more than nine names as Congress shall direct, shall in the presence of Congress be drawn out by lot, and the persons whose names shall be so drawn or any five of them, shall be commissioners or judges, to hear and finally determine the controversy, so always as a major part of the judges who shall hear the cause shall agree in the determination: and if either party shall neglect to attend at the day appointed, without showing reasons, which Congress shall judge sufficient, or being present shall refuse to strike, the Congress shall proceed to nominate three persons out of each State, and the secretary of Congress shall strike in behalf of such party absent or refusing; and the judgement and sentence of the court to be appointed, in the manner before prescribed, shall be final and conclusive; and if any of the parties shall refuse to submit to the authority of such court, or to appear or defend their claim or cause, the court shall nevertheless proceed to pronounce sentence, or judgement, which shall in like manner be final and decisive, the judgement or sentence and other proceedings being in either case transmitted to Congress, and lodged among the acts of Congress for the security of the parties concerned: provided that every commissioner, before he sits in judgement, shall take an oath to be administered by one of the judges of the supreme or superior court of the State, where the cause shall be tried, 'well and truly to hear and determine the matter in question, according to the best of his judgement, without favor, affection or hope of reward': provided also, that no State shall be deprived of territory for the benefit of the United States.\n\n"
                                                                          @"All controversies concerning the private right of soil claimed under different grants of two or more States, whose jurisdictions as they may respect such lands, and the States which passed such grants are adjusted, the said grants or either of them being at the same time claimed to have originated antecedent to such settlement of jurisdiction, shall on the petition of either party to the Congress of the United States, be finally determined as near as may be in the same manner as is before prescribed for deciding disputes respecting territorial jurisdiction between different States.\n\n"
                                                                          @"The United States in Congress assembled shall also have the sole and exclusive right and power of regulating the alloy and value of coin struck by their own authority, or by that of the respective States — fixing the standards of weights and measures throughout the United States — regulating the trade and managing all affairs with the Indians, not members of any of the States, provided that the legislative right of any State within its own limits be not infringed or violated — establishing or regulating post offices from one State to another, throughout all the United States, and exacting such postage on the papers passing through the same as may be requisite to defray the expenses of the said office — appointing all officers of the land forces, in the service of the United States, excepting regimental officers — appointing all the officers of the naval forces, and commissioning all officers whatever in the service of the United States — making rules for the government and regulation of the said land and naval forces, and directing their operations.\n\n"
                                                                          @"The United States in Congress assembled shall have authority to appoint a committee, to sit in the recess of Congress, to be denominated 'A Committee of the States', and to consist of one delegate from each State; and to appoint such other committees and civil officers as may be necessary for managing the general affairs of the United States under their direction — to appoint one of their members to preside, provided that no person be allowed to serve in the office of president more than one year in any term of three years; to ascertain the necessary sums of money to be raised for the service of the United States, and to appropriate and apply the same for defraying the public expenses — to borrow money, or emit bills on the credit of the United States, transmitting every half-year to the respective States an account of the sums of money so borrowed or emitted — to build and equip a navy — to agree upon the number of land forces, and to make requisitions from each State for its quota, in proportion to the number of white inhabitants in such State; which requisition shall be binding, and thereupon the legislature of each State shall appoint the regimental officers, raise the men and cloath, arm and equip them in a solid- like manner, at the expense of the United States; and the officers and men so cloathed, armed and equipped shall march to the place appointed, and within the time agreed on by the United States in Congress assembled. But if the United States in Congress assembled shall, on consideration of circumstances judge proper that any State should not raise men, or should raise a smaller number of men than the quota thereof, such extra number shall be raised, officered, cloathed, armed and equipped in the same manner as the quota of each State, unless the legislature of such State shall judge that such extra number cannot be safely spread out in the same, in which case they shall raise, officer, cloath, arm and equip as many of such extra number as they judge can be safely spared. And the officers and men so cloathed, armed, and equipped, shall march to the place appointed, and within the time agreed on by the United States in Congress assembled.\n\n"
                                                                          @"The United States in Congress assembled shall never engage in a war, nor grant letters of marque or reprisal in time of peace, nor enter into any treaties or alliances, nor coin money, nor regulate the value thereof, nor ascertain the sums and expenses necessary for the defense and welfare of the United States, or any of them, nor emit bills, nor borrow money on the credit of the United States, nor appropriate money, nor agree upon the number of vessels of war, to be built or purchased, or the number of land or sea forces to be raised, nor appoint a commander in chief of the army or navy, unless nine States assent to the same: nor shall a question on any other point, except for adjourning from day to day be determined, unless by the votes of the majority of the United States in Congress assembled.\n\n"
                                                                          @"The Congress of the United States shall have power to adjourn to any time within the year, and to any place within the United States, so that no period of adjournment be for a longer duration than the space of six months, and shall publish the journal of their proceedings monthly, except such parts thereof relating to treaties, alliances or military operations, as in their judgement require secrecy; and the yeas and nays of the delegates of each State on any question shall be entered on the journal, when it is desired by any delegates of a State, or any of them, at his or their request shall be furnished with a transcript of the said journal, except such parts as are above excepted, to lay before the legislatures of the several States.", nil)]],
     [Article articleWithTitle:@"Article X"
                       section:[Section sectionWithText:NSLocalizedString(@"The Committee of the States, or any nine of them, shall be authorized to execute, in the recess of Congress, such of the powers of Congress as the United States in Congress assembled, by the consent of the nine States, shall from time to time think expedient to vest them with; provided that no power be delegated to the said Committee, for the exercise of which, by the Articles of Confederation, the voice of nine States in the Congress of the United States assembled be requisite.", nil)]],
     [Article articleWithTitle:@"Article XI"
                       section:[Section sectionWithText:NSLocalizedString(@"Canada acceding to this confederation, and adjoining in the measures of the United States, shall be admitted into, and entitled to all the advantages of this Union; but no other colony shall be admitted into the same, unless such admission be agreed to by nine States.", nil)]],
     [Article articleWithTitle:@"Article XII"
                       section:[Section sectionWithText:NSLocalizedString(@"All bills of credit emitted, monies borrowed, and debts contracted by, or under the authority of Congress, before the assembling of the United States, in pursuance of the present confederation, shall be deemed and considered as a charge against the United States, for payment and satisfaction whereof the said United States, and the public faith are hereby solemnly pledged.", nil)]],
     [Article articleWithTitle:@"Article XIII"
                       section:[Section sectionWithText:NSLocalizedString(@"Every State shall abide by the determination of the United States in Congress assembled, on all questions which by this confederation are submitted to them. And the Articles of this Confederation shall be inviolably observed by every State, and the Union shall be perpetual; nor shall any alteration at any time hereafter be made in any of them; unless such alteration be agreed to in a Congress of the United States, and be afterwards confirmed by the legislatures of every State.", nil)]],
     
     nil];
    
    NSString* conclusion = @"And Whereas it hath pleased the Great Governor of the World to incline the hearts of the legislatures we respectively represent in Congress, to approve of, and to authorize us to ratify the said Articles of Confederation and perpetual Union. Know Ye that we the undersigned delegates, by virtue of the power and authority to us given for that purpose, do by these presents, in the name and in behalf of our respective constituents, fully and entirely ratify and confirm each and every of the said Articles of Confederation and perpetual Union, and all and singular the matters and things therein contained: And we do further solemnly plight and engage the faith of our respective constituents, that they shall abide by the determinations of the United States in Congress assembled, on all questions, which by the said Confederation are submitted to them. And that the Articles thereof shall be inviolably observed by the States we respectively represent, and that the Union shall be perpetual.";
    
    MultiDictionary* signers = [MultiDictionary dictionary];
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Josiah Bartlett", @"http://en.wikipedia.org/wiki/Josiah_Bartlett"),
                         person(@"John Wentworth Jr.", @"http://en.wikipedia.org/wiki/John_Wentworth_Jr."),nil]
                 forKey:@"New Hampshire"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Hancock", @"http://en.wikipedia.org/wiki/John_Hancock"),
                         person(@"Samuel Adams", @"http://en.wikipedia.org/wiki/Samuel_Adams"),
                         person(@"Elbridge Gerry", @"http://en.wikipedia.org/wiki/Elbridge_Gerry"),
                         person(@"Francis Dana", @"http://en.wikipedia.org/wiki/Francis_Dana"),
                         person(@"James Lovell", @"http://en.wikipedia.org/wiki/James_Lovell_(delegate)"),
                         person(@"Samuel Holten", @"http://en.wikipedia.org/wiki/Samuel_Holten"),nil]
                 forKey:@"Massachusetts"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"William Ellery", @"http://en.wikipedia.org/wiki/William_Ellery"),
                         person(@"Henry Marchant", @"http://en.wikipedia.org/wiki/Henry_Marchant"),
                         person(@"John Collins", @"http://en.wikipedia.org/wiki/John_Collins_(delegate)"),nil]
                 forKey:@"Rhode Island"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Roger Sherman", @"http://en.wikipedia.org/wiki/Roger_Sherman"),
                         person(@"Samuel Huntington", @"http://en.wikipedia.org/wiki/Samuel_Huntington_(statesman)"),
                         person(@"Oliver Wolcott", @"http://en.wikipedia.org/wiki/Oliver_Wolcott"),
                         person(@"Titus Hosmer", @"http://en.wikipedia.org/wiki/Titus_Hosmer"),
                         person(@"Andrew Adams", @"http://en.wikipedia.org/wiki/Andrew_Adams_(congressman)"),nil]
                 forKey:@"Connecticut"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"James Duane", @"http://en.wikipedia.org/wiki/James_Duane"),
                         person(@"Francis Lewis", @"http://en.wikipedia.org/wiki/Francis_Lewis"),
                         person(@"William Duer", @"http://en.wikipedia.org/wiki/William_Duer_(1747-1799)"),
                         person(@"Gouverneur Morris", @"http://en.wikipedia.org/wiki/Gouverneur_Morris"),nil]
                 forKey:@"New York"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Witherspoon", @"http://en.wikipedia.org/wiki/John_Witherspoon"),
                         person(@"Nathaniel Scudder", @"http://en.wikipedia.org/wiki/Nathaniel_Scudder"),nil]
                 forKey:@"New Jersey"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Robert Morris", @"http://en.wikipedia.org/wiki/Robert_Morris_(financier)"),
                         person(@"Daniel Roberdeau", @"http://en.wikipedia.org/wiki/Daniel_Roberdeau"),
                         person(@"John Bayard Smith", @"http://en.wikipedia.org/wiki/Jonathan_Bayard_Smith"),
                         person(@"William Clingan", @"http://en.wikipedia.org/wiki/William_Clingan"),
                         person(@"Joseph Reed", @"http://en.wikipedia.org/wiki/Joseph_Reed_(jurist)"),nil]
                 forKey:@"Pennsylvania"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Thomas Mckean", @"http://en.wikipedia.org/wiki/Thomas_McKean"),
                         person(@"John Dickinson", @"http://en.wikipedia.org/wiki/John_Dickinson_(delegate)"),
                         person(@"Nicholas Van Dyke", @"http://en.wikipedia.org/wiki/Nicholas_Van_Dyke_(governor)"),nil]
                 forKey:@"Deleware"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Hanson", @"http://en.wikipedia.org/wiki/John_Hanson"),
                         person(@"Daniel Carroll", @"http://en.wikipedia.org/wiki/Daniel_Carroll"),nil]
                 forKey:@"Maryland"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Richard Henry Lee", @"http://en.wikipedia.org/wiki/Richard_Henry_Lee"),
                         person(@"John Banister", @"http://en.wikipedia.org/wiki/John_Banister_(lawyer)"),
                         person(@"Thomas Adams", @"http://en.wikipedia.org/wiki/Thomas_Adams_(politician)"),
                         person(@"John Harvie", @"http://en.wikipedia.org/wiki/John_Harvie"),
                         person(@"Francis Lightfoot Lee", @"http://en.wikipedia.org/wiki/Francis_Lightfoot_Lee"),nil]
                 forKey:@"Virginia"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"John Penn", @"http://en.wikipedia.org/wiki/John_Penn_(delegate)"),
                         person(@"Cornelius Harnett", @"http://www.google.com/url?q=http://en.wikipedia.org/wiki/Cornelius_Harnett&ei=NkioSYigCYH8tgfN7MHXDw&sa=X&oi=spellmeleon_result&resnum=1&ct=result&cd=1&usg=AFQjCNHDpzuq6d5jPavCHKx2E2VgIvpFGQ"),
                         person(@"John Williams", @"http://en.wikipedia.org/wiki/John_Williams_(delegate)"),nil]
                 forKey:@"North Carolina"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"Henry Laurens", @"http://en.wikipedia.org/wiki/Henry_Laurens"),
                         person(@"William Henry Drayton", @"http://en.wikipedia.org/wiki/William_Henry_Drayton"),
                         person(@"Jno Mathews", @"http://en.wikipedia.org/wiki/John_Mathews"),
                         person(@"Richard Hutson", @"http://www.google.com/url?q=http://en.wikipedia.org/wiki/Richard_Hutson"),
                         person(@"Thomas Heyward Jr.", @"http://en.wikipedia.org/wiki/Thomas_Heyward,_Jr."),nil]
                 forKey:@"South Carolina"];
    
    [signers addObjects:[NSArray arrayWithObjects:
                         person(@"George Walton", @"http://en.wikipedia.org/wiki/George_Walton"),
                         person(@"Edward Telfair", @"http://en.wikipedia.org/wiki/Edward_Telfair"),
                         person(@"Edward Langworthy", @"http://en.wikipedia.org/wiki/Edward_Langworthy"),nil]
                 forKey:@"Georgia"];
    
    articlesOfConfederation = 
    [[Constitution constitutionWithCountry:country
                                  preamble:preamble
                                  articles:articles
                                amendments:[NSArray array]
                                conclusion:conclusion
                                   signers:signers] retain];
}


+ (void) setupFederalistPapers {
    NSString* country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:@"US"];    
    
    NSArray* articles =
    [NSArray arrayWithObjects:
     [Article articleWithTitle:NSLocalizedString(@"Importance of the Union", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:
                                [Section sectionWithTitle:@"General Introduction" text:@"To the People of the State of New York:\n\n"
                                 @"AFTER an unequivocal experience of the inefficiency of the subsisting federal government, you are called upon to deliberate on a new Constitution for the United States of America. The subject speaks its own importance; comprehending in its consequences nothing less than the existence of the UNION, the safety and welfare of the parts of which it is composed, the fate of an empire in many respects the most interesting in the world. It has been frequently remarked that it seems to have been reserved to the people of this country, by their conduct and example, to decide the important question, whether societies of men are really capable or not of establishing good government from reflection and choice, or whether they are forever destined to depend for their political constitutions on accident and force. If there be any truth in the remark, the crisis at which we are arrived may with propriety be regarded as the era in which that decision is to be made; and a wrong election of the part we shall act may, in this view, deserve to be considered as the general misfortune of mankind.\n\n"
                                 @"This idea will add the inducements of philanthropy to those of patriotism, to heighten the solicitude which all considerate and good men must feel for the event. Happy will it be if our choice should be directed by a judicious estimate of our true interests, unperplexed and unbiased by considerations not connected with the public good. But this is a thing more ardently to be wished than seriously to be expected. The plan offered to our deliberations affects too many particular interests, innovates upon too many local institutions, not to involve in its discussion a variety of objects foreign to its merits, and of views, passions and prejudices little favorable to the discovery of truth.\n\n"
                                 @"Among the most formidable of the obstacles which the new Constitution will have to encounter may readily be distinguished the obvious interest of a certain class of men in every State to resist all changes which may hazard a diminution of the power, emolument, and consequence of the offices they hold under the State establishments; and the perverted ambition of another class of men, who will either hope to aggrandize themselves by the confusions of their country, or will flatter themselves with fairer prospects of elevation from the subdivision of the empire into several partial confederacies than from its union under one government.\n\n"
                                 @"It is not, however, my design to dwell upon observations of this nature. I am well aware that it would be disingenuous to resolve indiscriminately the opposition of any set of men (merely because their situations might subject them to suspicion) into interested or ambitious views. Candor will oblige us to admit that even such men may be actuated by upright intentions; and it cannot be doubted that much of the opposition which has made its appearance, or may hereafter make its appearance, will spring from sources, blameless at least, if not respectable--the honest errors of minds led astray by preconceived jealousies and fears. So numerous indeed and so powerful are the causes which serve to give a false bias to the judgment, that we, upon many occasions, see wise and good men on the wrong as well as on the right side of questions of the first magnitude to society. This circumstance, if duly attended to, would furnish a lesson of moderation to those who are ever so much persuaded of their being in the right in any controversy. And a further reason for caution, in this respect, might be drawn from the reflection that we are not always sure that those who advocate the truth are influenced by purer principles than their antagonists. Ambition, avarice, personal animosity, party opposition, and many other motives not more laudable than these, are apt to operate as well upon those who support as those who oppose the right side of a question. Were there not even these inducements to moderation, nothing could be more ill-judged than that intolerant spirit which has, at all times, characterized political parties. For in politics, as in religion, it is equally absurd to aim at making proselytes by fire and sword. Heresies in either can rarely be cured by persecution.\n\n"
                                 @"And yet, however just these sentiments will be allowed to be, we have already sufficient indications that it will happen in this as in all former cases of great national discussion. A torrent of angry and malignant passions will be let loose. To judge from the conduct of the opposite parties, we shall be led to conclude that they will mutually hope to evince the justness of their opinions, and to increase the number of their converts by the loudness of their declamations and the bitterness of their invectives. An enlightened zeal for the energy and efficiency of government will be stigmatized as the offspring of a temper fond of despotic power and hostile to the principles of liberty. An over-scrupulous jealousy of danger to the rights of the people, which is more commonly the fault of the head than of the heart, will be represented as mere pretense and artifice, the stale bait for popularity at the expense of the public good. It will be forgotten, on the one hand, that jealousy is the usual concomitant of love, and that the noble enthusiasm of liberty is apt to be infected with a spirit of narrow and illiberal distrust. On the other hand, it will be equally forgotten that the vigor of government is essential to the security of liberty; that, in the contemplation of a sound and well-informed judgment, their interest can never be separated; and that a dangerous ambition more often lurks behind the specious mask of zeal for the rights of the people than under the forbidden appearance of zeal for the firmness and efficiency of government. History will teach us that the former has been found a much more certain road to the introduction of despotism than the latter, and that of those men who have overturned the liberties of republics, the greatest number have begun their career by paying an obsequious court to the people; commencing demagogues, and ending tyrants.\n\n"
                                 @"In the course of the preceding observations, I have had an eye, my fellow-citizens, to putting you upon your guard against all attempts, from whatever quarter, to influence your decision in a matter of the utmost moment to your welfare, by any impressions other than those which may result from the evidence of truth. You will, no doubt, at the same time, have collected from the general scope of them, that they proceed from a source not unfriendly to the new Constitution. Yes, my countrymen, I own to you that, after having given it an attentive consideration, I am clearly of opinion it is your interest to adopt it. I am convinced that this is the safest course for your liberty, your dignity, and your happiness. I affect not reserves which I do not feel. I will not amuse you with an appearance of deliberation when I have decided. I frankly acknowledge to you my convictions, and I will freely lay before you the reasons on which they are founded. The consciousness of good intentions disdains ambiguity. I shall not, however, multiply professions on this head. My motives must remain in the depository of my own breast. My arguments will be open to all, and may be judged of by all. They shall at least be offered in a spirit which will not disgrace the cause of truth.\n\n"
                                 @"I propose, in a series of papers, to discuss the following interesting particulars:\n\n"
                                 @"• THE UTILITY OF THE UNION TO YOUR POLITICAL PROSPERITY\n"
                                 @"• THE INSUFFICIENCY OF THE PRESENT CONFEDERATION TO PRESERVE THAT UNION\n"
                                 @"• THE NECESSITY OF A GOVERNMENT AT LEAST EQUALLY ENERGETIC WITH THE ONE PROPOSED, TO THE ATTAINMENT OF THIS OBJECT\n"
                                 @"• THE CONFORMITY OF THE PROPOSED CONSTITUTION TO THE TRUE PRINCIPLES OF REPUBLICAN GOVERNMENT\n"
                                 @"• ITS ANALOGY TO YOUR OWN STATE CONSTITUTION\n"
                                 @"• and lastly, THE ADDITIONAL SECURITY WHICH ITS ADOPTION WILL AFFORD TO THE PRESERVATION OF THAT SPECIES OF GOVERNMENT, TO LIBERTY, AND TO PROPERTY.\n\n"
                                 @"In the progress of this discussion I shall endeavor to give a satisfactory answer to all the objections which shall have made their appearance, that may seem to have any claim to your attention.\n\n"
                                 @"It may perhaps be thought superfluous to offer arguments to prove the utility of the UNION, a point, no doubt, deeply engraved on the hearts of the great body of the people in every State, and one, which it may be imagined, has no adversaries. But the fact is, that we already hear it whispered in the private circles of those who oppose the new Constitution, that the thirteen States are of too great extent for any general system, and that we must of necessity resort to separate confederacies of distinct portions of the whole.1 This doctrine will, in all probability, be gradually propagated, till it has votaries enough to countenance an open avowal of it. For nothing can be more evident, to those who are able to take an enlarged view of the subject, than the alternative of an adoption of the new Constitution or a dismemberment of the Union. It will therefore be of use to begin by examining the advantages of that Union, the certain evils, and the probable dangers, to which every State will be exposed from its dissolution. This shall accordingly constitute the subject of my next address."],
                                [Section sectionWithTitle:@"Concerning Dangers from Foreign Force and Influence (1)" text:@"To the People of the State of New York:\n\n"
                                 @"WHEN the people of America reflect that they are now called upon to decide a question, which, in its consequences, must prove one of the most important that ever engaged their attention, the propriety of their taking a very comprehensive, as well as a very serious, view of it, will be evident.\n\n"
                                 @"Nothing is more certain than the indispensable necessity of government, and it is equally undeniable, that whenever and however it is instituted, the people must cede to it some of their natural rights in order to vest it with requisite powers. It is well worthy of consideration therefore, whether it would conduce more to the interest of the people of America that they should, to all general purposes, be one nation, under one federal government, or that they should divide themselves into separate confederacies, and give to the head of each the same kind of powers which they are advised to place in one national government.\n\n"
                                 @"It has until lately been a received and uncontradicted opinion that the prosperity of the people of America depended on their continuing firmly united, and the wishes, prayers, and efforts of our best and wisest citizens have been constantly directed to that object. But politicians now appear, who insist that this opinion is erroneous, and that instead of looking for safety and happiness in union, we ought to seek it in a division of the States into distinct confederacies or sovereignties. However extraordinary this new doctrine may appear, it nevertheless has its advocates; and certain characters who were much opposed to it formerly, are at present of the number. Whatever may be the arguments or inducements which have wrought this change in the sentiments and declarations of these gentlemen, it certainly would not be wise in the people at large to adopt these new political tenets without being fully convinced that they are founded in truth and sound policy.\n\n"
                                 @"It has often given me pleasure to observe that independent America was not composed of detached and distant territories, but that one connected, fertile, widespreading country was the portion of our western sons of liberty. Providence has in a particular manner blessed it with a variety of soils and productions, and watered it with innumerable streams, for the delight and accommodation of its inhabitants. A succession of navigable waters forms a kind of chain round its borders, as if to bind it together; while the most noble rivers in the world, running at convenient distances, present them with highways for the easy communication of friendly aids, and the mutual transportation and exchange of their various commodities.\n\n"
                                 @"With equal pleasure I have as often taken notice that Providence has been pleased to give this one connected country to one united people--a people descended from the same ancestors, speaking the same language, professing the same religion, attached to the same principles of government, very similar in their manners and customs, and who, by their joint counsels, arms, and efforts, fighting side by side throughout a long and bloody war, have nobly established general liberty and independence.\n\n"
                                 @"This country and this people seem to have been made for each other, and it appears as if it was the design of Providence, that an inheritance so proper and convenient for a band of brethren, united to each other by the strongest ties, should never be split into a number of unsocial, jealous, and alien sovereignties.\n\n"
                                 @"Similar sentiments have hitherto prevailed among all orders and denominations of men among us. To all general purposes we have uniformly been one people each individual citizen everywhere enjoying the same national rights, privileges, and protection. As a nation we have made peace and war; as a nation we have vanquished our common enemies; as a nation we have formed alliances, and made treaties, and entered into various compacts and conventions with foreign states.\n\n"
                                 @"A strong sense of the value and blessings of union induced the people, at a very early period, to institute a federal government to preserve and perpetuate it. They formed it almost as soon as they had a political existence; nay, at a time when their habitations were in flames, when many of their citizens were bleeding, and when the progress of hostility and desolation left little room for those calm and mature inquiries and reflections which must ever precede the formation of a wise and wellbalanced government for a free people. It is not to be wondered at, that a government instituted in times so inauspicious, should on experiment be found greatly deficient and inadequate to the purpose it was intended to answer.\n\n"
                                 @"This intelligent people perceived and regretted these defects. Still continuing no less attached to union than enamored of liberty, they observed the danger which immediately threatened the former and more remotely the latter; and being pursuaded that ample security for both could only be found in a national government more wisely framed, they as with one voice, convened the late convention at Philadelphia, to take that important subject under consideration.\n\n"
                                 @"This convention composed of men who possessed the confidence of the people, and many of whom had become highly distinguished by their patriotism, virtue and wisdom, in times which tried the minds and hearts of men, undertook the arduous task. In the mild season of peace, with minds unoccupied by other subjects, they passed many months in cool, uninterrupted, and daily consultation; and finally, without having been awed by power, or influenced by any passions except love for their country, they presented and recommended to the people the plan produced by their joint and very unanimous councils.\n\n"
                                 @"Admit, for so is the fact, that this plan is only RECOMMENDED, not imposed, yet let it be remembered that it is neither recommended to BLIND approbation, nor to BLIND reprobation; but to that sedate and candid consideration which the magnitude and importance of the subject demand, and which it certainly ought to receive. But this (as was remarked in the foregoing number of this paper) is more to be wished than expected, that it may be so considered and examined. Experience on a former occasion teaches us not to be too sanguine in such hopes. It is not yet forgotten that well-grounded apprehensions of imminent danger induced the people of America to form the memorable Congress of 1774. That body recommended certain measures to their constituents, and the event proved their wisdom; yet it is fresh in our memories how soon the press began to teem with pamphlets and weekly papers against those very measures. Not only many of the officers of government, who obeyed the dictates of personal interest, but others, from a mistaken estimate of consequences, or the undue influence of former attachments, or whose ambition aimed at objects which did not correspond with the public good, were indefatigable in their efforts to pursuade the people to reject the advice of that patriotic Congress. Many, indeed, were deceived and deluded, but the great majority of the people reasoned and decided judiciously; and happy they are in reflecting that they did so.\n\n"
                                 @"They considered that the Congress was composed of many wise and experienced men. That, being convened from different parts of the country, they brought with them and communicated to each other a variety of useful information. That, in the course of the time they passed together in inquiring into and discussing the true interests of their country, they must have acquired very accurate knowledge on that head. That they were individually interested in the public liberty and prosperity, and therefore that it was not less their inclination than their duty to recommend only such measures as, after the most mature deliberation, they really thought prudent and advisable.\n\n"
                                 @"These and similar considerations then induced the people to rely greatly on the judgment and integrity of the Congress; and they took their advice, notwithstanding the various arts and endeavors used to deter them from it. But if the people at large had reason to confide in the men of that Congress, few of whom had been fully tried or generally known, still greater reason have they now to respect the judgment and advice of the convention, for it is well known that some of the most distinguished members of that Congress, who have been since tried and justly approved for patriotism and abilities, and who have grown old in acquiring political information, were also members of this convention, and carried into it their accumulated knowledge and experience.\n\n"
                                 @"It is worthy of remark that not only the first, but every succeeding Congress, as well as the late convention, have invariably joined with the people in thinking that the prosperity of America depended on its Union. To preserve and perpetuate it was the great object of the people in forming that convention, and it is also the great object of the plan which the convention has advised them to adopt. With what propriety, therefore, or for what good purposes, are attempts at this particular period made by some men to depreciate the importance of the Union? Or why is it suggested that three or four confederacies would be better than one? I am persuaded in my own mind that the people have always thought right on this subject, and that their universal and uniform attachment to the cause of the Union rests on great and weighty reasons, which I shall endeavor to develop and explain in some ensuing papers. They who promote the idea of substituting a number of distinct confederacies in the room of the plan of the convention, seem clearly to foresee that the rejection of it would put the continuance of the Union in the utmost jeopardy. That certainly would be the case, and I sincerely wish that it may be as clearly foreseen by every good citizen, that whenever the dissolution of the Union arrives, America will have reason to exclaim, in the words of the poet: 'FAREWELL! A LONG FAREWELL TO ALL MY GREATNESS.'"],
                                [Section sectionWithTitle:@"Concerning Dangers from Foreign Force and Influence (2)" text:@"To the People of the State of New York:\n\n"
                                 @"IT IS not a new observation that the people of any country (if, like the Americans, intelligent and wellinformed) seldom adopt and steadily persevere for many years in an erroneous opinion respecting their interests. That consideration naturally tends to create great respect for the high opinion which the people of America have so long and uniformly entertained of the importance of their continuing firmly united under one federal government, vested with sufficient powers for all general and national purposes.\n\n"
                                 @"The more attentively I consider and investigate the reasons which appear to have given birth to this opinion, the more I become convinced that they are cogent and conclusive.\n\n"
                                 @"Among the many objects to which a wise and free people find it necessary to direct their attention, that of providing for their SAFETY seems to be the first. The SAFETY of the people doubtless has relation to a great variety of circumstances and considerations, and consequently affords great latitude to those who wish to define it precisely and comprehensively.\n\n"
                                 @"At present I mean only to consider it as it respects security for the preservation of peace and tranquillity, as well as against dangers from FOREIGN ARMS AND INFLUENCE, as from dangers of the LIKE KIND arising from domestic causes. As the former of these comes first in order, it is proper it should be the first discussed. Let us therefore proceed to examine whether the people are not right in their opinion that a cordial Union, under an efficient national government, affords them the best security that can be devised against HOSTILITIES from abroad.\n\n"
                                 @"The number of wars which have happened or will happen in the world will always be found to be in proportion to the number and weight of the causes, whether REAL or PRETENDED, which PROVOKE or INVITE them. If this remark be just, it becomes useful to inquire whether so many JUST causes of war are likely to be given by UNITED AMERICA as by DISUNITED America; for if it should turn out that United America will probably give the fewest, then it will follow that in this respect the Union tends most to preserve the people in a state of peace with other nations.\n\n"
                                 @"The JUST causes of war, for the most part, arise either from violation of treaties or from direct violence. America has already formed treaties with no less than six foreign nations, and all of them, except Prussia, are maritime, and therefore able to annoy and injure us. She has also extensive commerce with Portugal, Spain, and Britain, and, with respect to the two latter, has, in addition, the circumstance of neighborhood to attend to.\n\n"
                                 @"It is of high importance to the peace of America that she observe the laws of nations towards all these powers, and to me it appears evident that this will be more perfectly and punctually done by one national government than it could be either by thirteen separate States or by three or four distinct confederacies.\n\n"
                                 @"Because when once an efficient national government is established, the best men in the country will not only consent to serve, but also will generally be appointed to manage it; for, although town or country, or other contracted influence, may place men in State assemblies, or senates, or courts of justice, or executive departments, yet more general and extensive reputation for talents and other qualifications will be necessary to recommend men to offices under the national government,--especially as it will have the widest field for choice, and never experience that want of proper persons which is not uncommon in some of the States. Hence, it will result that the administration, the political counsels, and the judicial decisions of the national government will be more wise, systematical, and judicious than those of individual States, and consequently more satisfactory with respect to other nations, as well as more SAFE with respect to us.\n\n"
                                 @"Because, under the national government, treaties and articles of treaties, as well as the laws of nations, will always be expounded in one sense and executed in the same manner,--whereas, adjudications on the same points and questions, in thirteen States, or in three or four confederacies, will not always accord or be consistent; and that, as well from the variety of independent courts and judges appointed by different and independent governments, as from the different local laws and interests which may affect and influence them. The wisdom of the convention, in committing such questions to the jurisdiction and judgment of courts appointed by and responsible only to one national government, cannot be too much commended.\n\n"
                                 @"Because the prospect of present loss or advantage may often tempt the governing party in one or two States to swerve from good faith and justice; but those temptations, not reaching the other States, and consequently having little or no influence on the national government, the temptation will be fruitless, and good faith and justice be preserved. The case of the treaty of peace with Britain adds great weight to this reasoning.\n\n"
                                 @"Because, even if the governing party in a State should be disposed to resist such temptations, yet as such temptations may, and commonly do, result from circumstances peculiar to the State, and may affect a great number of the inhabitants, the governing party may not always be able, if willing, to prevent the injustice meditated, or to punish the aggressors. But the national government, not being affected by those local circumstances, will neither be induced to commit the wrong themselves, nor want power or inclination to prevent or punish its commission by others.\n\n"
                                 @"So far, therefore, as either designed or accidental violations of treaties and the laws of nations afford JUST causes of war, they are less to be apprehended under one general government than under several lesser ones, and in that respect the former most favors the SAFETY of the people.\n\n"
                                 @"As to those just causes of war which proceed from direct and unlawful violence, it appears equally clear to me that one good national government affords vastly more security against dangers of that sort than can be derived from any other quarter.\n\n"
                                 @"Because such violences are more frequently caused by the passions and interests of a part than of the whole; of one or two States than of the Union. Not a single Indian war has yet been occasioned by aggressions of the present federal government, feeble as it is; but there are several instances of Indian hostilities having been provoked by the improper conduct of individual States, who, either unable or unwilling to restrain or punish offenses, have given occasion to the slaughter of many innocent inhabitants.\n\n"
                                 @"The neighborhood of Spanish and British territories, bordering on some States and not on others, naturally confines the causes of quarrel more immediately to the borderers. The bordering States, if any, will be those who, under the impulse of sudden irritation, and a quick sense of apparent interest or injury, will be most likely, by direct violence, to excite war with these nations; and nothing can so effectually obviate that danger as a national government, whose wisdom and prudence will not be diminished by the passions which actuate the parties immediately interested.\n\n"
                                 @"But not only fewer just causes of war will be given by the national government, but it will also be more in their power to accommodate and settle them amicably. They will be more temperate and cool, and in that respect, as well as in others, will be more in capacity to act advisedly than the offending State. The pride of states, as well as of men, naturally disposes them to justify all their actions, and opposes their acknowledging, correcting, or repairing their errors and offenses. The national government, in such cases, will not be affected by this pride, but will proceed with moderation and candor to consider and decide on the means most proper to extricate them from the difficulties which threaten them.\n\n"
                                 @"Besides, it is well known that acknowledgments, explanations, and compensations are often accepted as satisfactory from a strong united nation, which would be rejected as unsatisfactory if offered by a State or confederacy of little consideration or power.\n\n"
                                 @"In the year 1685, the state of Genoa having offended Louis XIV., endeavored to appease him. He demanded that they should send their Doge, or chief magistrate, accompanied by four of their senators, to FRANCE, to ask his pardon and receive his terms. They were obliged to submit to it for the sake of peace. Would he on any occasion either have demanded or have received the like humiliation from Spain, or Britain, or any other POWERFUL nation?"],
                                [Section sectionWithTitle:@"Concerning Dangers from Foreign Force and Influence (3)" text:@"To the People of the State of New York:\n\n"
                                 @"MY LAST paper assigned several reasons why the safety of the people would be best secured by union against the danger it may be exposed to by JUST causes of war given to other nations; and those reasons show that such causes would not only be more rarely given, but would also be more easily accommodated, by a national government than either by the State governments or the proposed little confederacies.\n\n"
                                 @"But the safety of the people of America against dangers from FOREIGN force depends not only on their forbearing to give JUST causes of war to other nations, but also on their placing and continuing themselves in such a situation as not to INVITE hostility or insult; for it need not be observed that there are PRETENDED as well as just causes of war.\n\n"
                                 @"It is too true, however disgraceful it may be to human nature, that nations in general will make war whenever they have a prospect of getting anything by it; nay, absolute monarchs will often make war when their nations are to get nothing by it, but for the purposes and objects merely personal, such as thirst for military glory, revenge for personal affronts, ambition, or private compacts to aggrandize or support their particular families or partisans. These and a variety of other motives, which affect only the mind of the sovereign, often lead him to engage in wars not sanctified by justice or the voice and interests of his people. But, independent of these inducements to war, which are more prevalent in absolute monarchies, but which well deserve our attention, there are others which affect nations as often as kings; and some of them will on examination be found to grow out of our relative situation and circumstances.\n\n"
                                 @"With France and with Britain we are rivals in the fisheries, and can supply their markets cheaper than they can themselves, notwithstanding any efforts to prevent it by bounties on their own or duties on foreign fish.\n\n"
                                 @"With them and with most other European nations we are rivals in navigation and the carrying trade; and we shall deceive ourselves if we suppose that any of them will rejoice to see it flourish; for, as our carrying trade cannot increase without in some degree diminishing theirs, it is more their interest, and will be more their policy, to restrain than to promote it.\n\n"
                                 @"In the trade to China and India, we interfere with more than one nation, inasmuch as it enables us to partake in advantages which they had in a manner monopolized, and as we thereby supply ourselves with commodities which we used to purchase from them.\n\n"
                                 @"The extension of our own commerce in our own vessels cannot give pleasure to any nations who possess territories on or near this continent, because the cheapness and excellence of our productions, added to the circumstance of vicinity, and the enterprise and address of our merchants and navigators, will give us a greater share in the advantages which those territories afford, than consists with the wishes or policy of their respective sovereigns.\n\n"
                                 @"Spain thinks it convenient to shut the Mississippi against us on the one side, and Britain excludes us from the Saint Lawrence on the other; nor will either of them permit the other waters which are between them and us to become the means of mutual intercourse and traffic.\n\n"
                                 @"From these and such like considerations, which might, if consistent with prudence, be more amplified and detailed, it is easy to see that jealousies and uneasinesses may gradually slide into the minds and cabinets of other nations, and that we are not to expect that they should regard our advancement in union, in power and consequence by land and by sea, with an eye of indifference and composure.\n\n"
                                 @"The people of America are aware that inducements to war may arise out of these circumstances, as well as from others not so obvious at present, and that whenever such inducements may find fit time and opportunity for operation, pretenses to color and justify them will not be wanting. Wisely, therefore, do they consider union and a good national government as necessary to put and keep them in SUCH A SITUATION as, instead of INVITING war, will tend to repress and discourage it. That situation consists in the best possible state of defense, and necessarily depends on the government, the arms, and the resources of the country.\n\n"
                                 @"As the safety of the whole is the interest of the whole, and cannot be provided for without government, either one or more or many, let us inquire whether one good government is not, relative to the object in question, more competent than any other given number whatever.\n\n"
                                 @"One government can collect and avail itself of the talents and experience of the ablest men, in whatever part of the Union they may be found. It can move on uniform principles of policy. It can harmonize, assimilate, and protect the several parts and members, and extend the benefit of its foresight and precautions to each. In the formation of treaties, it will regard the interest of the whole, and the particular interests of the parts as connected with that of the whole. It can apply the resources and power of the whole to the defense of any particular part, and that more easily and expeditiously than State governments or separate confederacies can possibly do, for want of concert and unity of system. It can place the militia under one plan of discipline, and, by putting their officers in a proper line of subordination to the Chief Magistrate, will, as it were, consolidate them into one corps, and thereby render them more efficient than if divided into thirteen or into three or four distinct independent companies.\n\n"
                                 @"What would the militia of Britain be if the English militia obeyed the government of England, if the Scotch militia obeyed the government of Scotland, and if the Welsh militia obeyed the government of Wales? Suppose an invasion; would those three governments (if they agreed at all) be able, with all their respective forces, to operate against the enemy so effectually as the single government of Great Britain would?\n\n"
                                 @"We have heard much of the fleets of Britain, and the time may come, if we are wise, when the fleets of America may engage attention. But if one national government, had not so regulated the navigation of Britain as to make it a nursery for seamen--if one national government had not called forth all the national means and materials for forming fleets, their prowess and their thunder would never have been celebrated. Let England have its navigation and fleet--let Scotland have its navigation and fleet--let Wales have its navigation and fleet--let Ireland have its navigation and fleet--let those four of the constituent parts of the British empire be be under four independent governments, and it is easy to perceive how soon they would each dwindle into comparative insignificance.\n\n"
                                 @"Apply these facts to our own case. Leave America divided into thirteen or, if you please, into three or four independent governments--what armies could they raise and pay--what fleets could they ever hope to have? If one was attacked, would the others fly to its succor, and spend their blood and money in its defense? Would there be no danger of their being flattered into neutrality by its specious promises, or seduced by a too great fondness for peace to decline hazarding their tranquillity and present safety for the sake of neighbors, of whom perhaps they have been jealous, and whose importance they are content to see diminished? Although such conduct would not be wise, it would, nevertheless, be natural. The history of the states of Greece, and of other countries, abounds with such instances, and it is not improbable that what has so often happened would, under similar circumstances, happen again.\n\n"
                                 @"But admit that they might be willing to help the invaded State or confederacy. How, and when, and in what proportion shall aids of men and money be afforded? Who shall command the allied armies, and from which of them shall he receive his orders? Who shall settle the terms of peace, and in case of disputes what umpire shall decide between them and compel acquiescence? Various difficulties and inconveniences would be inseparable from such a situation; whereas one government, watching over the general and common interests, and combining and directing the powers and resources of the whole, would be free from all these embarrassments, and conduce far more to the safety of the people.\n\n"
                                 @"But whatever may be our situation, whether firmly united under one national government, or split into a number of confederacies, certain it is, that foreign nations will know and view it exactly as it is; and they will act toward us accordingly. If they see that our national government is efficient and well administered, our trade prudently regulated, our militia properly organized and disciplined, our resources and finances discreetly managed, our credit re-established, our people free, contented, and united, they will be much more disposed to cultivate our friendship than provoke our resentment. If, on the other hand, they find us either destitute of an effectual government (each State doing right or wrong, as to its rulers may seem convenient), or split into three or four independent and probably discordant republics or confederacies, one inclining to Britain, another to France, and a third to Spain, and perhaps played off against each other by the three, what a poor, pitiful figure will America make in their eyes! How liable would she become not only to their contempt but to their outrage, and how soon would dear-bought experience proclaim that when a people or family so divide, it never fails to be against themselves."],
                                [Section sectionWithTitle:@"Concerning Dangers from Foreign Force and Influence (4)" text:@"To the People of the State of New York:\n\n"
                                 @"QUEEN ANNE, in her letter of the 1st July, 1706, to the Scotch Parliament, makes some observations on the importance of the UNION then forming between England and Scotland, which merit our attention. I shall present the public with one or two extracts from it: 'An entire and perfect union will be the solid foundation of lasting peace: It will secure your religion, liberty, and property; remove the animosities amongst yourselves, and the jealousies and differences betwixt our two kingdoms. It must increase your strength, riches, and trade; and by this union the whole island, being joined in affection and free from all apprehensions of different interest, will be ENABLED TO RESIST ALL ITS ENEMIES.' 'We most earnestly recommend to you calmness and unanimity in this great and weighty affair, that the union may be brought to a happy conclusion, being the only EFFECTUAL way to secure our present and future happiness, and disappoint the designs of our and your enemies, who will doubtless, on this occasion, USE THEIR UTMOST ENDEAVORS TO PREVENT OR DELAY THIS UNION.'\n\n"
                                 @"It was remarked in the preceding paper, that weakness and divisions at home would invite dangers from abroad; and that nothing would tend more to secure us from them than union, strength, and good government within ourselves. This subject is copious and cannot easily be exhausted.\n\n"
                                 @"The history of Great Britain is the one with which we are in general the best acquainted, and it gives us many useful lessons. We may profit by their experience without paying the price which it cost them. Although it seems obvious to common sense that the people of such an island should be but one nation, yet we find that they were for ages divided into three, and that those three were almost constantly embroiled in quarrels and wars with one another. Notwithstanding their true interest with respect to the continental nations was really the same, yet by the arts and policy and practices of those nations, their mutual jealousies were perpetually kept inflamed, and for a long series of years they were far more inconvenient and troublesome than they were useful and assisting to each other.\n\n"
                                 @"Should the people of America divide themselves into three or four nations, would not the same thing happen? Would not similar jealousies arise, and be in like manner cherished? Instead of their being 'joined in affection' and free from all apprehension of different 'interests,' envy and jealousy would soon extinguish confidence and affection, and the partial interests of each confederacy, instead of the general interests of all America, would be the only objects of their policy and pursuits. Hence, like most other BORDERING nations, they would always be either involved in disputes and war, or live in the constant apprehension of them.\n\n"
                                 @"The most sanguine advocates for three or four confederacies cannot reasonably suppose that they would long remain exactly on an equal footing in point of strength, even if it was possible to form them so at first; but, admitting that to be practicable, yet what human contrivance can secure the continuance of such equality? Independent of those local circumstances which tend to beget and increase power in one part and to impede its progress in another, we must advert to the effects of that superior policy and good management which would probably distinguish the government of one above the rest, and by which their relative equality in strength and consideration would be destroyed. For it cannot be presumed that the same degree of sound policy, prudence, and foresight would uniformly be observed by each of these confederacies for a long succession of years.\n\n"
                                 @"Whenever, and from whatever causes, it might happen, and happen it would, that any one of these nations or confederacies should rise on the scale of political importance much above the degree of her neighbors, that moment would those neighbors behold her with envy and with fear. Both those passions would lead them to countenance, if not to promote, whatever might promise to diminish her importance; and would also restrain them from measures calculated to advance or even to secure her prosperity. Much time would not be necessary to enable her to discern these unfriendly dispositions. She would soon begin, not only to lose confidence in her neighbors, but also to feel a disposition equally unfavorable to them. Distrust naturally creates distrust, and by nothing is good-will and kind conduct more speedily changed than by invidious jealousies and uncandid imputations, whether expressed or implied.\n\n"
                                 @"The North is generally the region of strength, and many local circumstances render it probable that the most Northern of the proposed confederacies would, at a period not very distant, be unquestionably more formidable than any of the others. No sooner would this become evident than the NORTHERN HIVE would excite the same ideas and sensations in the more southern parts of America which it formerly did in the southern parts of Europe. Nor does it appear to be a rash conjecture that its young swarms might often be tempted to gather honey in the more blooming fields and milder air of their luxurious and more delicate neighbors.\n\n"
                                 @"They who well consider the history of similar divisions and confederacies will find abundant reason to apprehend that those in contemplation would in no other sense be neighbors than as they would be borderers; that they would neither love nor trust one another, but on the contrary would be a prey to discord, jealousy, and mutual injuries; in short, that they would place us exactly in the situations in which some nations doubtless wish to see us, viz., FORMIDABLE ONLY TO EACH OTHER.\n\n"
                                 @"From these considerations it appears that those gentlemen are greatly mistaken who suppose that alliances offensive and defensive might be formed between these confederacies, and would produce that combination and union of wills of arms and of resources, which would be necessary to put and keep them in a formidable state of defense against foreign enemies.\n\n"
                                 @"When did the independent states, into which Britain and Spain were formerly divided, combine in such alliance, or unite their forces against a foreign enemy? The proposed confederacies will be DISTINCT NATIONS. Each of them would have its commerce with foreigners to regulate by distinct treaties; and as their productions and commodities are different and proper for different markets, so would those treaties be essentially different. Different commercial concerns must create different interests, and of course different degrees of political attachment to and connection with different foreign nations. Hence it might and probably would happen that the foreign nation with whom the SOUTHERN confederacy might be at war would be the one with whom the NORTHERN confederacy would be the most desirous of preserving peace and friendship. An alliance so contrary to their immediate interest would not therefore be easy to form, nor, if formed, would it be observed and fulfilled with perfect good faith.\n\n"
                                 @"Nay, it is far more probable that in America, as in Europe, neighboring nations, acting under the impulse of opposite interests and unfriendly passions, would frequently be found taking different sides. Considering our distance from Europe, it would be more natural for these confederacies to apprehend danger from one another than from distant nations, and therefore that each of them should be more desirous to guard against the others by the aid of foreign alliances, than to guard against foreign dangers by alliances between themselves. And here let us not forget how much more easy it is to receive foreign fleets into our ports, and foreign armies into our country, than it is to persuade or compel them to depart. How many conquests did the Romans and others make in the characters of allies, and what innovations did they under the same character introduce into the governments of those whom they pretended to protect.\n\n"
                                 @"Let candid men judge, then, whether the division of America into any given number of independent sovereignties would tend to secure us against the hostilities and improper interference of foreign nations."],
                                [Section sectionWithTitle:@"Concerning Dangers from Dissensions Between the States (1)" text:@"To the People of the State of New York:\n\n"
                                 @"THE three last numbers of this paper have been dedicated to an enumeration of the dangers to which we should be exposed, in a state of disunion, from the arms and arts of foreign nations. I shall now proceed to delineate dangers of a different and, perhaps, still more alarming kind--those which will in all probability flow from dissensions between the States themselves, and from domestic factions and convulsions. These have been already in some instances slightly anticipated; but they deserve a more particular and more full investigation.\n\n"
                                 @"A man must be far gone in Utopian speculations who can seriously doubt that, if these States should either be wholly disunited, or only united in partial confederacies, the subdivisions into which they might be thrown would have frequent and violent contests with each other. To presume a want of motives for such contests as an argument against their existence, would be to forget that men are ambitious, vindictive, and rapacious. To look for a continuation of harmony between a number of independent, unconnected sovereignties in the same neighborhood, would be to disregard the uniform course of human events, and to set at defiance the accumulated experience of ages.\n\n"
                                 @"The causes of hostility among nations are innumerable. There are some which have a general and almost constant operation upon the collective bodies of society. Of this description are the love of power or the desire of pre-eminence and dominion--the jealousy of power, or the desire of equality and safety. There are others which have a more circumscribed though an equally operative influence within their spheres. Such are the rivalships and competitions of commerce between commercial nations. And there are others, not less numerous than either of the former, which take their origin entirely in private passions; in the attachments, enmities, interests, hopes, and fears of leading individuals in the communities of which they are members. Men of this class, whether the favorites of a king or of a people, have in too many instances abused the confidence they possessed; and assuming the pretext of some public motive, have not scrupled to sacrifice the national tranquillity to personal advantage or personal gratification.\n\n"
                                 @"The celebrated Pericles, in compliance with the resentment of a prostitute,1 at the expense of much of the blood and treasure of his countrymen, attacked, vanquished, and destroyed the city of the SAMNIANS. The same man, stimulated by private pique against the MEGARENSIANS,2 another nation of Greece, or to avoid a prosecution with which he was threatened as an accomplice of a supposed theft of the statuary Phidias,3 or to get rid of the accusations prepared to be brought against him for dissipating the funds of the state in the purchase of popularity,4 or from a combination of all these causes, was the primitive author of that famous and fatal war, distinguished in the Grecian annals by the name of the PELOPONNESIAN war; which, after various vicissitudes, intermissions, and renewals, terminated in the ruin of the Athenian commonwealth.\n\n"
                                 @"The ambitious cardinal, who was prime minister to Henry VIII., permitting his vanity to aspire to the triple crown,5 entertained hopes of succeeding in the acquisition of that splendid prize by the influence of the Emperor Charles V. To secure the favor and interest of this enterprising and powerful monarch, he precipitated England into a war with France, contrary to the plainest dictates of policy, and at the hazard of the safety and independence, as well of the kingdom over which he presided by his counsels, as of Europe in general. For if there ever was a sovereign who bid fair to realize the project of universal monarchy, it was the Emperor Charles V., of whose intrigues Wolsey was at once the instrument and the dupe.\n\n"
                                 @"The influence which the bigotry of one female,6 the petulance of another,7 and the cabals of a third,8 had in the contemporary policy, ferments, and pacifications, of a considerable part of Europe, are topics that have been too often descanted upon not to be generally known.\n\n"
                                 @"To multiply examples of the agency of personal considerations in the production of great national events, either foreign or domestic, according to their direction, would be an unnecessary waste of time. Those who have but a superficial acquaintance with the sources from which they are to be drawn, will themselves recollect a variety of instances; and those who have a tolerable knowledge of human nature will not stand in need of such lights to form their opinion either of the reality or extent of that agency. Perhaps, however, a reference, tending to illustrate the general principle, may with propriety be made to a case which has lately happened among ourselves. If Shays had not been a DESPERATE DEBTOR, it is much to be doubted whether Massachusetts would have been plunged into a civil war.\n\n"
                                 @"But notwithstanding the concurring testimony of experience, in this particular, there are still to be found visionary or designing men, who stand ready to advocate the paradox of perpetual peace between the States, though dismembered and alienated from each other. The genius of republics (say they) is pacific; the spirit of commerce has a tendency to soften the manners of men, and to extinguish those inflammable humors which have so often kindled into wars. Commercial republics, like ours, will never be disposed to waste themselves in ruinous contentions with each other. They will be governed by mutual interest, and will cultivate a spirit of mutual amity and concord.\n\n"
                                 @"Is it not (we may ask these projectors in politics) the true interest of all nations to cultivate the same benevolent and philosophic spirit? If this be their true interest, have they in fact pursued it? Has it not, on the contrary, invariably been found that momentary passions, and immediate interest, have a more active and imperious control over human conduct than general or remote considerations of policy, utility or justice? Have republics in practice been less addicted to war than monarchies? Are not the former administered by MEN as well as the latter? Are there not aversions, predilections, rivalships, and desires of unjust acquisitions, that affect nations as well as kings? Are not popular assemblies frequently subject to the impulses of rage, resentment, jealousy, avarice, and of other irregular and violent propensities? Is it not well known that their determinations are often governed by a few individuals in whom they place confidence, and are, of course, liable to be tinctured by the passions and views of those individuals? Has commerce hitherto done anything more than change the objects of war? Is not the love of wealth as domineering and enterprising a passion as that of power or glory? Have there not been as many wars founded upon commercial motives since that has become the prevailing system of nations, as were before occasioned by the cupidity of territory or dominion? Has not the spirit of commerce, in many instances, administered new incentives to the appetite, both for the one and for the other? Let experience, the least fallible guide of human opinions, be appealed to for an answer to these inquiries.\n\n"
                                 @"Sparta, Athens, Rome, and Carthage were all republics; two of them, Athens and Carthage, of the commercial kind. Yet were they as often engaged in wars, offensive and defensive, as the neighboring monarchies of the same times. Sparta was little better than a wellregulated camp; and Rome was never sated of carnage and conquest.\n\n"
                                 @"Carthage, though a commercial republic, was the aggressor in the very war that ended in her destruction. Hannibal had carried her arms into the heart of Italy and to the gates of Rome, before Scipio, in turn, gave him an overthrow in the territories of Carthage, and made a conquest of the commonwealth.\n\n"
                                 @"Venice, in later times, figured more than once in wars of ambition, till, becoming an object to the other Italian states, Pope Julius II. found means to accomplish that formidable league,9 which gave a deadly blow to the power and pride of this haughty republic.\n\n"
                                 @"The provinces of Holland, till they were overwhelmed in debts and taxes, took a leading and conspicuous part in the wars of Europe. They had furious contests with England for the dominion of the sea, and were among the most persevering and most implacable of the opponents of Louis XIV.\n\n"
                                 @"In the government of Britain the representatives of the people compose one branch of the national legislature. Commerce has been for ages the predominant pursuit of that country. Few nations, nevertheless, have been more frequently engaged in war; and the wars in which that kingdom has been engaged have, in numerous instances, proceeded from the people.\n\n"
                                 @"There have been, if I may so express it, almost as many popular as royal wars. The cries of the nation and the importunities of their representatives have, upon various occasions, dragged their monarchs into war, or continued them in it, contrary to their inclinations, and sometimes contrary to the real interests of the State. In that memorable struggle for superiority between the rival houses of AUSTRIA and BOURBON, which so long kept Europe in a flame, it is well known that the antipathies of the English against the French, seconding the ambition, or rather the avarice, of a favorite leader,10 protracted the war beyond the limits marked out by sound policy, and for a considerable time in opposition to the views of the court.\n\n"
                                 @"The wars of these two last-mentioned nations have in a great measure grown out of commercial considerations,--the desire of supplanting and the fear of being supplanted, either in particular branches of traffic or in the general advantages of trade and navigation.\n\n"
                                 @"From this summary of what has taken place in other countries, whose situations have borne the nearest resemblance to our own, what reason can we have to confide in those reveries which would seduce us into an expectation of peace and cordiality between the members of the present confederacy, in a state of separation? Have we not already seen enough of the fallacy and extravagance of those idle theories which have amused us with promises of an exemption from the imperfections, weaknesses and evils incident to society in every shape? Is it not time to awake from the deceitful dream of a golden age, and to adopt as a practical maxim for the direction of our political conduct that we, as well as the other inhabitants of the globe, are yet remote from the happy empire of perfect wisdom and perfect virtue?\n\n"
                                 @"Let the point of extreme depression to which our national dignity and credit have sunk, let the inconveniences felt everywhere from a lax and ill administration of government, let the revolt of a part of the State of North Carolina, the late menacing disturbances in Pennsylvania, and the actual insurrections and rebellions in Massachusetts, declare--!\n\n"
                                 @"So far is the general sense of mankind from corresponding with the tenets of those who endeavor to lull asleep our apprehensions of discord and hostility between the States, in the event of disunion, that it has from long observation of the progress of society become a sort of axiom in politics, that vicinity or nearness of situation, constitutes nations natural enemies. An intelligent writer expresses himself on this subject to this effect: 'NEIGHBORING NATIONS (says he) are naturally enemies of each other unless their common weakness forces them to league in a CONFEDERATE REPUBLIC, and their constitution prevents the differences that neighborhood occasions, extinguishing that secret jealousy which disposes all states to aggrandize themselves at the expense of their neighbors.' This passage, at the same time, points out the EVIL and suggests the REMEDY."
                                ],
                                [Section sectionWithTitle:@"Concerning Dangers from Dissensions Between the States (2)" text:@"To the People of the State of New York:\n\n"
                                 @"IT IS sometimes asked, with an air of seeming triumph, what inducements could the States have, if disunited, to make war upon each other? It would be a full answer to this question to say--precisely the same inducements which have, at different times, deluged in blood all the nations in the world. But, unfortunately for us, the question admits of a more particular answer. There are causes of differences within our immediate contemplation, of the tendency of which, even under the restraints of a federal constitution, we have had sufficient experience to enable us to form a judgment of what might be expected if those restraints were removed.\n\n"
                                 @"Territorial disputes have at all times been found one of the most fertile sources of hostility among nations. Perhaps the greatest proportion of wars that have desolated the earth have sprung from this origin. This cause would exist among us in full force. We have a vast tract of unsettled territory within the boundaries of the United States. There still are discordant and undecided claims between several of them, and the dissolution of the Union would lay a foundation for similar claims between them all. It is well known that they have heretofore had serious and animated discussion concerning the rights to the lands which were ungranted at the time of the Revolution, and which usually went under the name of crown lands. The States within the limits of whose colonial governments they were comprised have claimed them as their property, the others have contended that the rights of the crown in this article devolved upon the Union; especially as to all that part of the Western territory which, either by actual possession, or through the submission of the Indian proprietors, was subjected to the jurisdiction of the king of Great Britain, till it was relinquished in the treaty of peace. This, it has been said, was at all events an acquisition to the Confederacy by compact with a foreign power. It has been the prudent policy of Congress to appease this controversy, by prevailing upon the States to make cessions to the United States for the benefit of the whole. This has been so far accomplished as, under a continuation of the Union, to afford a decided prospect of an amicable termination of the dispute. A dismemberment of the Confederacy, however, would revive this dispute, and would create others on the same subject. At present, a large part of the vacant Western territory is, by cession at least, if not by any anterior right, the common property of the Union. If that were at an end, the States which made the cession, on a principle of federal compromise, would be apt when the motive of the grant had ceased, to reclaim the lands as a reversion. The other States would no doubt insist on a proportion, by right of representation. Their argument would be, that a grant, once made, could not be revoked; and that the justice of participating in territory acquired or secured by the joint efforts of the Confederacy, remained undiminished. If, contrary to probability, it should be admitted by all the States, that each had a right to a share of this common stock, there would still be a difficulty to be surmounted, as to a proper rule of apportionment. Different principles would be set up by different States for this purpose; and as they would affect the opposite interests of the parties, they might not easily be susceptible of a pacific adjustment.\n\n"
                                 @"In the wide field of Western territory, therefore, we perceive an ample theatre for hostile pretensions, without any umpire or common judge to interpose between the contending parties. To reason from the past to the future, we shall have good ground to apprehend, that the sword would sometimes be appealed to as the arbiter of their differences. The circumstances of the dispute between Connecticut and Pennsylvania, respecting the land at Wyoming, admonish us not to be sanguine in expecting an easy accommodation of such differences. The articles of confederation obliged the parties to submit the matter to the decision of a federal court. The submission was made, and the court decided in favor of Pennsylvania. But Connecticut gave strong indications of dissatisfaction with that determination; nor did she appear to be entirely resigned to it, till, by negotiation and management, something like an equivalent was found for the loss she supposed herself to have sustained. Nothing here said is intended to convey the slightest censure on the conduct of that State. She no doubt sincerely believed herself to have been injured by the decision; and States, like individuals, acquiesce with great reluctance in determinations to their disadvantage.\n\n"
                                 @"Those who had an opportunity of seeing the inside of the transactions which attended the progress of the controversy between this State and the district of Vermont, can vouch the opposition we experienced, as well from States not interested as from those which were interested in the claim; and can attest the danger to which the peace of the Confederacy might have been exposed, had this State attempted to assert its rights by force. Two motives preponderated in that opposition: one, a jealousy entertained of our future power; and the other, the interest of certain individuals of influence in the neighboring States, who had obtained grants of lands under the actual government of that district. Even the States which brought forward claims, in contradiction to ours, seemed more solicitous to dismember this State, than to establish their own pretensions. These were New Hampshire, Massachusetts, and Connecticut. New Jersey and Rhode Island, upon all occasions, discovered a warm zeal for the independence of Vermont; and Maryland, till alarmed by the appearance of a connection between Canada and that State, entered deeply into the same views. These being small States, saw with an unfriendly eye the perspective of our growing greatness. In a review of these transactions we may trace some of the causes which would be likely to embroil the States with each other, if it should be their unpropitious destiny to become disunited.\n\n"
                                 @"The competitions of commerce would be another fruitful source of contention. The States less favorably circumstanced would be desirous of escaping from the disadvantages of local situation, and of sharing in the advantages of their more fortunate neighbors. Each State, or separate confederacy, would pursue a system of commercial policy peculiar to itself. This would occasion distinctions, preferences, and exclusions, which would beget discontent. The habits of intercourse, on the basis of equal privileges, to which we have been accustomed since the earliest settlement of the country, would give a keener edge to those causes of discontent than they would naturally have independent of this circumstance. WE SHOULD BE READY TO DENOMINATE INJURIES THOSE THINGS WHICH WERE IN REALITY THE JUSTIFIABLE ACTS OF INDEPENDENT SOVEREIGNTIES CONSULTING A DISTINCT INTEREST. The spirit of enterprise, which characterizes the commercial part of America, has left no occasion of displaying itself unimproved. It is not at all probable that this unbridled spirit would pay much respect to those regulations of trade by which particular States might endeavor to secure exclusive benefits to their own citizens. The infractions of these regulations, on one side, the efforts to prevent and repel them, on the other, would naturally lead to outrages, and these to reprisals and wars.\n\n"
                                 @"The opportunities which some States would have of rendering others tributary to them by commercial regulations would be impatiently submitted to by the tributary States. The relative situation of New York, Connecticut, and New Jersey would afford an example of this kind. New York, from the necessities of revenue, must lay duties on her importations. A great part of these duties must be paid by the inhabitants of the two other States in the capacity of consumers of what we import. New York would neither be willing nor able to forego this advantage. Her citizens would not consent that a duty paid by them should be remitted in favor of the citizens of her neighbors; nor would it be practicable, if there were not this impediment in the way, to distinguish the customers in our own markets. Would Connecticut and New Jersey long submit to be taxed by New York for her exclusive benefit? Should we be long permitted to remain in the quiet and undisturbed enjoyment of a metropolis, from the possession of which we derived an advantage so odious to our neighbors, and, in their opinion, so oppressive? Should we be able to preserve it against the incumbent weight of Connecticut on the one side, and the co-operating pressure of New Jersey on the other? These are questions that temerity alone will answer in the affirmative.\n\n"
                                 @"The public debt of the Union would be a further cause of collision between the separate States or confederacies. The apportionment, in the first instance, and the progressive extinguishment afterward, would be alike productive of ill-humor and animosity. How would it be possible to agree upon a rule of apportionment satisfactory to all? There is scarcely any that can be proposed which is entirely free from real objections. These, as usual, would be exaggerated by the adverse interest of the parties. There are even dissimilar views among the States as to the general principle of discharging the public debt. Some of them, either less impressed with the importance of national credit, or because their citizens have little, if any, immediate interest in the question, feel an indifference, if not a repugnance, to the payment of the domestic debt at any rate. These would be inclined to magnify the difficulties of a distribution. Others of them, a numerous body of whose citizens are creditors to the public beyond proportion of the State in the total amount of the national debt, would be strenuous for some equitable and effective provision. The procrastinations of the former would excite the resentments of the latter. The settlement of a rule would, in the meantime, be postponed by real differences of opinion and affected delays. The citizens of the States interested would clamour; foreign powers would urge for the satisfaction of their just demands, and the peace of the States would be hazarded to the double contingency of external invasion and internal contention.\n\n"
                                 @"Suppose the difficulties of agreeing upon a rule surmounted, and the apportionment made. Still there is great room to suppose that the rule agreed upon would, upon experiment, be found to bear harder upon some States than upon others. Those which were sufferers by it would naturally seek for a mitigation of the burden. The others would as naturally be disinclined to a revision, which was likely to end in an increase of their own incumbrances. Their refusal would be too plausible a pretext to the complaining States to withhold their contributions, not to be embraced with avidity; and the non-compliance of these States with their engagements would be a ground of bitter discussion and altercation. If even the rule adopted should in practice justify the equality of its principle, still delinquencies in payments on the part of some of the States would result from a diversity of other causes--the real deficiency of resources; the mismanagement of their finances; accidental disorders in the management of the government; and, in addition to the rest, the reluctance with which men commonly part with money for purposes that have outlived the exigencies which produced them, and interfere with the supply of immediate wants. Delinquencies, from whatever causes, would be productive of complaints, recriminations, and quarrels. There is, perhaps, nothing more likely to disturb the tranquillity of nations than their being bound to mutual contributions for any common object that does not yield an equal and coincident benefit. For it is an observation, as true as it is trite, that there is nothing men differ so readily about as the payment of money.\n\n"
                                 @"Laws in violation of private contracts, as they amount to aggressions on the rights of those States whose citizens are injured by them, may be considered as another probable source of hostility. We are not authorized to expect that a more liberal or more equitable spirit would preside over the legislations of the individual States hereafter, if unrestrained by any additional checks, than we have heretofore seen in too many instances disgracing their several codes. We have observed the disposition to retaliation excited in Connecticut in consequence of the enormities perpetrated by the Legislature of Rhode Island; and we reasonably infer that, in similar cases, under other circumstances, a war, not of PARCHMENT, but of the sword, would chastise such atrocious breaches of moral obligation and social justice.\n\n"
                                 @"The probability of incompatible alliances between the different States or confederacies and different foreign nations, and the effects of this situation upon the peace of the whole, have been sufficiently unfolded in some preceding papers. From the view they have exhibited of this part of the subject, this conclusion is to be drawn, that America, if not connected at all, or only by the feeble tie of a simple league, offensive and defensive, would, by the operation of such jarring alliances, be gradually entangled in all the pernicious labyrinths of European politics and wars; and by the destructive contentions of the parts into which she was divided, would be likely to become a prey to the artifices and machinations of powers equally the enemies of them all. Divide et impera1 must be the motto of every nation that either hates or fears us."],
                                [Section sectionWithTitle:@"The Consequences of Hostilities Between the States" text:@"To the People of the State of New York:\n\n"
                                 @"ASSUMING it therefore as an established truth that the several States, in case of disunion, or such combinations of them as might happen to be formed out of the wreck of the general Confederacy, would be subject to those vicissitudes of peace and war, of friendship and enmity, with each other, which have fallen to the lot of all neighboring nations not united under one government, let us enter into a concise detail of some of the consequences that would attend such a situation.\n\n"
                                 @"War between the States, in the first period of their separate existence, would be accompanied with much greater distresses than it commonly is in those countries where regular military establishments have long obtained. The disciplined armies always kept on foot on the continent of Europe, though they bear a malignant aspect to liberty and economy, have, notwithstanding, been productive of the signal advantage of rendering sudden conquests impracticable, and of preventing that rapid desolation which used to mark the progress of war prior to their introduction. The art of fortification has contributed to the same ends. The nations of Europe are encircled with chains of fortified places, which mutually obstruct invasion. Campaigns are wasted in reducing two or three frontier garrisons, to gain admittance into an enemy's country. Similar impediments occur at every step, to exhaust the strength and delay the progress of an invader. Formerly, an invading army would penetrate into the heart of a neighboring country almost as soon as intelligence of its approach could be received; but now a comparatively small force of disciplined troops, acting on the defensive, with the aid of posts, is able to impede, and finally to frustrate, the enterprises of one much more considerable. The history of war, in that quarter of the globe, is no longer a history of nations subdued and empires overturned, but of towns taken and retaken; of battles that decide nothing; of retreats more beneficial than victories; of much effort and little acquisition.\n\n"
                                 @"In this country the scene would be altogether reversed. The jealousy of military establishments would postpone them as long as possible. The want of fortifications, leaving the frontiers of one state open to another, would facilitate inroads. The populous States would, with little difficulty, overrun their less populous neighbors. Conquests would be as easy to be made as difficult to be retained. War, therefore, would be desultory and predatory. PLUNDER and devastation ever march in the train of irregulars. The calamities of individuals would make the principal figure in the events which would characterize our military exploits.\n\n"
                                 @"This picture is not too highly wrought; though, I confess, it would not long remain a just one. Safety from external danger is the most powerful director of national conduct. Even the ardent love of liberty will, after a time, give way to its dictates. The violent destruction of life and property incident to war, the continual effort and alarm attendant on a state of continual danger, will compel nations the most attached to liberty to resort for repose and security to institutions which have a tendency to destroy their civil and political rights. To be more safe, they at length become willing to run the risk of being less free.\n\n"
                                 @"The institutions chiefly alluded to are STANDING ARMIES and the correspondent appendages of military establishments. Standing armies, it is said, are not provided against in the new Constitution; and it is therefore inferred that they may exist under it.1 Their existence, however, from the very terms of the proposition, is, at most, problematical and uncertain. But standing armies, it may be replied, must inevitably result from a dissolution of the Confederacy. Frequent war and constant apprehension, which require a state of as constant preparation, will infallibly produce them. The weaker States or confederacies would first have recourse to them, to put themselves upon an equality with their more potent neighbors. They would endeavor to supply the inferiority of population and resources by a more regular and effective system of defense, by disciplined troops, and by fortifications. They would, at the same time, be necessitated to strengthen the executive arm of government, in doing which their constitutions would acquire a progressive direction toward monarchy. It is of the nature of war to increase the executive at the expense of the legislative authority.\n\n"
                                 @"The expedients which have been mentioned would soon give the States or confederacies that made use of them a superiority over their neighbors. Small states, or states of less natural strength, under vigorous governments, and with the assistance of disciplined armies, have often triumphed over large states, or states of greater natural strength, which have been destitute of these advantages. Neither the pride nor the safety of the more important States or confederacies would permit them long to submit to this mortifying and adventitious superiority. They would quickly resort to means similar to those by which it had been effected, to reinstate themselves in their lost pre-eminence. Thus, we should, in a little time, see established in every part of this country the same engines of despotism which have been the scourge of the Old World. This, at least, would be the natural course of things; and our reasonings will be the more likely to be just, in proportion as they are accommodated to this standard.\n\n"
                                 @"These are not vague inferences drawn from supposed or speculative defects in a Constitution, the whole power of which is lodged in the hands of a people, or their representatives and delegates, but they are solid conclusions, drawn from the natural and necessary progress of human affairs.\n\n"
                                 @"It may, perhaps, be asked, by way of objection to this, why did not standing armies spring up out of the contentions which so often distracted the ancient republics of Greece? Different answers, equally satisfactory, may be given to this question. The industrious habits of the people of the present day, absorbed in the pursuits of gain, and devoted to the improvements of agriculture and commerce, are incompatible with the condition of a nation of soldiers, which was the true condition of the people of those republics. The means of revenue, which have been so greatly multiplied by the increase of gold and silver and of the arts of industry, and the science of finance, which is the offspring of modern times, concurring with the habits of nations, have produced an entire revolution in the system of war, and have rendered disciplined armies, distinct from the body of the citizens, the inseparable companions of frequent hostility.\n\n"
                                 @"There is a wide difference, also, between military establishments in a country seldom exposed by its situation to internal invasions, and in one which is often subject to them, and always apprehensive of them. The rulers of the former can have a good pretext, if they are even so inclined, to keep on foot armies so numerous as must of necessity be maintained in the latter. These armies being, in the first case, rarely, if at all, called into activity for interior defense, the people are in no danger of being broken to military subordination. The laws are not accustomed to relaxations, in favor of military exigencies; the civil state remains in full vigor, neither corrupted, nor confounded with the principles or propensities of the other state. The smallness of the army renders the natural strength of the community an over-match for it; and the citizens, not habituated to look up to the military power for protection, or to submit to its oppressions, neither love nor fear the soldiery; they view them with a spirit of jealous acquiescence in a necessary evil, and stand ready to resist a power which they suppose may be exerted to the prejudice of their rights. The army under such circumstances may usefully aid the magistrate to suppress a small faction, or an occasional mob, or insurrection; but it will be unable to enforce encroachments against the united efforts of the great body of the people.\n\n"
                                 @"In a country in the predicament last described, the contrary of all this happens. The perpetual menacings of danger oblige the government to be always prepared to repel it; its armies must be numerous enough for instant defense. The continual necessity for their services enhances the importance of the soldier, and proportionably degrades the condition of the citizen. The military state becomes elevated above the civil. The inhabitants of territories, often the theatre of war, are unavoidably subjected to frequent infringements on their rights, which serve to weaken their sense of those rights; and by degrees the people are brought to consider the soldiery not only as their protectors, but as their superiors. The transition from this disposition to that of considering them masters, is neither remote nor difficult; but it is very difficult to prevail upon a people under such impressions, to make a bold or effectual resistance to usurpations supported by the military power.\n\n"
                                 @"The kingdom of Great Britain falls within the first description. An insular situation, and a powerful marine, guarding it in a great measure against the possibility of foreign invasion, supersede the necessity of a numerous army within the kingdom. A sufficient force to make head against a sudden descent, till the militia could have time to rally and embody, is all that has been deemed requisite. No motive of national policy has demanded, nor would public opinion have tolerated, a larger number of troops upon its domestic establishment. There has been, for a long time past, little room for the operation of the other causes, which have been enumerated as the consequences of internal war. This peculiar felicity of situation has, in a great degree, contributed to preserve the liberty which that country to this day enjoys, in spite of the prevalent venality and corruption. If, on the contrary, Britain had been situated on the continent, and had been compelled, as she would have been, by that situation, to make her military establishments at home coextensive with those of the other great powers of Europe, she, like them, would in all probability be, at this day, a victim to the absolute power of a single man. 'T is possible, though not easy, that the people of that island may be enslaved from other causes; but it cannot be by the prowess of an army so inconsiderable as that which has been usually kept up within the kingdom.\n\n"
                                 @"If we are wise enough to preserve the Union we may for ages enjoy an advantage similar to that of an insulated situation. Europe is at a great distance from us. Her colonies in our vicinity will be likely to continue too much disproportioned in strength to be able to give us any dangerous annoyance. Extensive military establishments cannot, in this position, be necessary to our security. But if we should be disunited, and the integral parts should either remain separated, or, which is most probable, should be thrown together into two or three confederacies, we should be, in a short course of time, in the predicament of the continental powers of Europe --our liberties would be a prey to the means of defending ourselves against the ambition and jealousy of each other.\n\n"
                                 @"This is an idea not superficial or futile, but solid and weighty. It deserves the most serious and mature consideration of every prudent and honest man of whatever party. If such men will make a firm and solemn pause, and meditate dispassionately on the importance of this interesting idea; if they will contemplate it in all its attitudes, and trace it to all its consequences, they will not hesitate to part with trivial objections to a Constitution, the rejection of which would in all probability put a final period to the Union. The airy phantoms that flit before the distempered imaginations of some of its adversaries would quickly give place to the more substantial forms of dangers, real, certain, and formidable."],
                                [Section sectionWithTitle:@"The Union as a Safeguard Against Domestic Faction and Insurrection (1)" text:@"To the People of the State of New York:\n\n"
                                 @"A FIRM Union will be of the utmost moment to the peace and liberty of the States, as a barrier against domestic faction and insurrection. It is impossible to read the history of the petty republics of Greece and Italy without feeling sensations of horror and disgust at the distractions with which they were continually agitated, and at the rapid succession of revolutions by which they were kept in a state of perpetual vibration between the extremes of tyranny and anarchy. If they exhibit occasional calms, these only serve as short-lived contrast to the furious storms that are to succeed. If now and then intervals of felicity open to view, we behold them with a mixture of regret, arising from the reflection that the pleasing scenes before us are soon to be overwhelmed by the tempestuous waves of sedition and party rage. If momentary rays of glory break forth from the gloom, while they dazzle us with a transient and fleeting brilliancy, they at the same time admonish us to lament that the vices of government should pervert the direction and tarnish the lustre of those bright talents and exalted endowments for which the favored soils that produced them have been so justly celebrated.\n\n"
                                 @"From the disorders that disfigure the annals of those republics the advocates of despotism have drawn arguments, not only against the forms of republican government, but against the very principles of civil liberty. They have decried all free government as inconsistent with the order of society, and have indulged themselves in malicious exultation over its friends and partisans. Happily for mankind, stupendous fabrics reared on the basis of liberty, which have flourished for ages, have, in a few glorious instances, refuted their gloomy sophisms. And, I trust, America will be the broad and solid foundation of other edifices, not less magnificent, which will be equally permanent monuments of their errors.\n\n"
                                 @"But it is not to be denied that the portraits they have sketched of republican government were too just copies of the originals from which they were taken. If it had been found impracticable to have devised models of a more perfect structure, the enlightened friends to liberty would have been obliged to abandon the cause of that species of government as indefensible. The science of politics, however, like most other sciences, has received great improvement. The efficacy of various principles is now well understood, which were either not known at all, or imperfectly known to the ancients. The regular distribution of power into distinct departments; the introduction of legislative balances and checks; the institution of courts composed of judges holding their offices during good behavior; the representation of the people in the legislature by deputies of their own election: these are wholly new discoveries, or have made their principal progress towards perfection in modern times. They are means, and powerful means, by which the excellences of republican government may be retained and its imperfections lessened or avoided. To this catalogue of circumstances that tend to the amelioration of popular systems of civil government, I shall venture, however novel it may appear to some, to add one more, on a principle which has been made the foundation of an objection to the new Constitution; I mean the ENLARGEMENT of the ORBIT within which such systems are to revolve, either in respect to the dimensions of a single State or to the consolidation of several smaller States into one great Confederacy. The latter is that which immediately concerns the object under consideration. It will, however, be of use to examine the principle in its application to a single State, which shall be attended to in another place.\n\n"
                                 @"The utility of a Confederacy, as well to suppress faction and to guard the internal tranquillity of States, as to increase their external force and security, is in reality not a new idea. It has been practiced upon in different countries and ages, and has received the sanction of the most approved writers on the subject of politics. The opponents of the plan proposed have, with great assiduity, cited and circulated the observations of Montesquieu on the necessity of a contracted territory for a republican government. But they seem not to have been apprised of the sentiments of that great man expressed in another part of his work, nor to have adverted to the consequences of the principle to which they subscribe with such ready acquiescence.\n\n"
                                 @"When Montesquieu recommends a small extent for republics, the standards he had in view were of dimensions far short of the limits of almost every one of these States. Neither Virginia, Massachusetts, Pennsylvania, New York, North Carolina, nor Georgia can by any means be compared with the models from which he reasoned and to which the terms of his description apply. If we therefore take his ideas on this point as the criterion of truth, we shall be driven to the alternative either of taking refuge at once in the arms of monarchy, or of splitting ourselves into an infinity of little, jealous, clashing, tumultuous commonwealths, the wretched nurseries of unceasing discord, and the miserable objects of universal pity or contempt. Some of the writers who have come forward on the other side of the question seem to have been aware of the dilemma; and have even been bold enough to hint at the division of the larger States as a desirable thing. Such an infatuated policy, such a desperate expedient, might, by the multiplication of petty offices, answer the views of men who possess not qualifications to extend their influence beyond the narrow circles of personal intrigue, but it could never promote the greatness or happiness of the people of America.\n\n"
                                 @"Referring the examination of the principle itself to another place, as has been already mentioned, it will be sufficient to remark here that, in the sense of the author who has been most emphatically quoted upon the occasion, it would only dictate a reduction of the SIZE of the more considerable MEMBERS of the Union, but would not militate against their being all comprehended in one confederate government. And this is the true question, in the discussion of which we are at present interested.\n\n"
                                 @"So far are the suggestions of Montesquieu from standing in opposition to a general Union of the States, that he explicitly treats of a CONFEDERATE REPUBLIC as the expedient for extending the sphere of popular government, and reconciling the advantages of monarchy with those of republicanism. 'It is very probable,' (says he1) 'that mankind would have been obliged at length to live constantly under the government of a single person, had they not contrived a kind of constitution that has all the internal advantages of a republican, together with the external force of a monarchical government. I mean a CONFEDERATE REPUBLIC.\n\n"
                                 @"This form of government is a convention by which several smaller STATES agree to become members of a larger ONE, which they intend to form. It is a kind of assemblage of societies that constitute a new one, capable of increasing, by means of new associations, till they arrive to such a degree of power as to be able to provide for the security of the united body.\n\n"
                                 @"A republic of this kind, able to withstand an external force, may support itself without any internal corruptions. The form of this society prevents all manner of inconveniences.\n\n"
                                 @"If a single member should attempt to usurp the supreme authority, he could not be supposed to have an equal authority and credit in all the confederate states. Were he to have too great influence over one, this would alarm the rest. Were he to subdue a part, that which would still remain free might oppose him with forces independent of those which he had usurped and overpower him before he could be settled in his usurpation.\n\n"
                                 @"Should a popular insurrection happen in one of the confederate states the others are able to quell it. Should abuses creep into one part, they are reformed by those that remain sound. The state may be destroyed on one side, and not on the other; the confederacy may be dissolved, and the confederates preserve their sovereignty.\n\n"
                                 @"As this government is composed of small republics, it enjoys the internal happiness of each; and with respect to its external situation, it is possessed, by means of the association, of all the advantages of large monarchies.'\n\n"
                                 @"I have thought it proper to quote at length these interesting passages, because they contain a luminous abridgment of the principal arguments in favor of the Union, and must effectually remove the false impressions which a misapplication of other parts of the work was calculated to make. They have, at the same time, an intimate connection with the more immediate design of this paper; which is, to illustrate the tendency of the Union to repress domestic faction and insurrection.\n\n"
                                 @"A distinction, more subtle than accurate, has been raised between a CONFEDERACY and a CONSOLIDATION of the States. The essential characteristic of the first is said to be, the restriction of its authority to the members in their collective capacities, without reaching to the individuals of whom they are composed. It is contended that the national council ought to have no concern with any object of internal administration. An exact equality of suffrage between the members has also been insisted upon as a leading feature of a confederate government. These positions are, in the main, arbitrary; they are supported neither by principle nor precedent. It has indeed happened, that governments of this kind have generally operated in the manner which the distinction taken notice of, supposes to be inherent in their nature; but there have been in most of them extensive exceptions to the practice, which serve to prove, as far as example will go, that there is no absolute rule on the subject. And it will be clearly shown in the course of this investigation that as far as the principle contended for has prevailed, it has been the cause of incurable disorder and imbecility in the government.\n\n"
                                 @"The definition of a CONFEDERATE REPUBLIC seems simply to be 'an assemblage of societies,' or an association of two or more states into one state. The extent, modifications, and objects of the federal authority are mere matters of discretion. So long as the separate organization of the members be not abolished; so long as it exists, by a constitutional necessity, for local purposes; though it should be in perfect subordination to the general authority of the union, it would still be, in fact and in theory, an association of states, or a confederacy. The proposed Constitution, so far from implying an abolition of the State governments, makes them constituent parts of the national sovereignty, by allowing them a direct representation in the Senate, and leaves in their possession certain exclusive and very important portions of sovereign power. This fully corresponds, in every rational import of the terms, with the idea of a federal government.\n\n"
                                 @"In the Lycian confederacy, which consisted of twenty-three CITIES or republics, the largest were entitled to THREE votes in the COMMON COUNCIL, those of the middle class to TWO, and the smallest to ONE. The COMMON COUNCIL had the appointment of all the judges and magistrates of the respective CITIES. This was certainly the most, delicate species of interference in their internal administration; for if there be any thing that seems exclusively appropriated to the local jurisdictions, it is the appointment of their own officers. Yet Montesquieu, speaking of this association, says: 'Were I to give a model of an excellent Confederate Republic, it would be that of Lycia.' Thus we perceive that the distinctions insisted upon were not within the contemplation of this enlightened civilian; and we shall be led to conclude, that they are the novel refinements of an erroneous theory."],
                                [Section sectionWithTitle:@"The Union as a Safeguard Against Domestic Faction and Insurrection (2)" text:@"To the People of the State of New York:\n\n"
                                 @"AMONG the numerous advantages promised by a wellconstructed Union, none deserves to be more accurately developed than its tendency to break and control the violence of faction. The friend of popular governments never finds himself so much alarmed for their character and fate, as when he contemplates their propensity to this dangerous vice. He will not fail, therefore, to set a due value on any plan which, without violating the principles to which he is attached, provides a proper cure for it. The instability, injustice, and confusion introduced into the public councils, have, in truth, been the mortal diseases under which popular governments have everywhere perished; as they continue to be the favorite and fruitful topics from which the adversaries to liberty derive their most specious declamations. The valuable improvements made by the American constitutions on the popular models, both ancient and modern, cannot certainly be too much admired; but it would be an unwarrantable partiality, to contend that they have as effectually obviated the danger on this side, as was wished and expected. Complaints are everywhere heard from our most considerate and virtuous citizens, equally the friends of public and private faith, and of public and personal liberty, that our governments are too unstable, that the public good is disregarded in the conflicts of rival parties, and that measures are too often decided, not according to the rules of justice and the rights of the minor party, but by the superior force of an interested and overbearing majority. However anxiously we may wish that these complaints had no foundation, the evidence, of known facts will not permit us to deny that they are in some degree true. It will be found, indeed, on a candid review of our situation, that some of the distresses under which we labor have been erroneously charged on the operation of our governments; but it will be found, at the same time, that other causes will not alone account for many of our heaviest misfortunes; and, particularly, for that prevailing and increasing distrust of public engagements, and alarm for private rights, which are echoed from one end of the continent to the other. These must be chiefly, if not wholly, effects of the unsteadiness and injustice with which a factious spirit has tainted our public administrations.\n\n"
                                 @"By a faction, I understand a number of citizens, whether amounting to a majority or a minority of the whole, who are united and actuated by some common impulse of passion, or of interest, adversed to the rights of other citizens, or to the permanent and aggregate interests of the community.\n\n"
                                 @"There are two methods of curing the mischiefs of faction: the one, by removing its causes; the other, by controlling its effects.\n\n"
                                 @"There are again two methods of removing the causes of faction: the one, by destroying the liberty which is essential to its existence; the other, by giving to every citizen the same opinions, the same passions, and the same interests.\n\n"
                                 @"It could never be more truly said than of the first remedy, that it was worse than the disease. Liberty is to faction what air is to fire, an aliment without which it instantly expires. But it could not be less folly to abolish liberty, which is essential to political life, because it nourishes faction, than it would be to wish the annihilation of air, which is essential to animal life, because it imparts to fire its destructive agency.\n\n"
                                 @"The second expedient is as impracticable as the first would be unwise. As long as the reason of man continues fallible, and he is at liberty to exercise it, different opinions will be formed. As long as the connection subsists between his reason and his self-love, his opinions and his passions will have a reciprocal influence on each other; and the former will be objects to which the latter will attach themselves. The diversity in the faculties of men, from which the rights of property originate, is not less an insuperable obstacle to a uniformity of interests. The protection of these faculties is the first object of government. From the protection of different and unequal faculties of acquiring property, the possession of different degrees and kinds of property immediately results; and from the influence of these on the sentiments and views of the respective proprietors, ensues a division of the society into different interests and parties.\n\n"
                                 @"The latent causes of faction are thus sown in the nature of man; and we see them everywhere brought into different degrees of activity, according to the different circumstances of civil society. A zeal for different opinions concerning religion, concerning government, and many other points, as well of speculation as of practice; an attachment to different leaders ambitiously contending for pre-eminence and power; or to persons of other descriptions whose fortunes have been interesting to the human passions, have, in turn, divided mankind into parties, inflamed them with mutual animosity, and rendered them much more disposed to vex and oppress each other than to co-operate for their common good. So strong is this propensity of mankind to fall into mutual animosities, that where no substantial occasion presents itself, the most frivolous and fanciful distinctions have been sufficient to kindle their unfriendly passions and excite their most violent conflicts. But the most common and durable source of factions has been the various and unequal distribution of property. Those who hold and those who are without property have ever formed distinct interests in society. Those who are creditors, and those who are debtors, fall under a like discrimination. A landed interest, a manufacturing interest, a mercantile interest, a moneyed interest, with many lesser interests, grow up of necessity in civilized nations, and divide them into different classes, actuated by different sentiments and views. The regulation of these various and interfering interests forms the principal task of modern legislation, and involves the spirit of party and faction in the necessary and ordinary operations of the government.\n\n"
                                 @"No man is allowed to be a judge in his own cause, because his interest would certainly bias his judgment, and, not improbably, corrupt his integrity. With equal, nay with greater reason, a body of men are unfit to be both judges and parties at the same time; yet what are many of the most important acts of legislation, but so many judicial determinations, not indeed concerning the rights of single persons, but concerning the rights of large bodies of citizens? And what are the different classes of legislators but advocates and parties to the causes which they determine? Is a law proposed concerning private debts? It is a question to which the creditors are parties on one side and the debtors on the other. Justice ought to hold the balance between them. Yet the parties are, and must be, themselves the judges; and the most numerous party, or, in other words, the most powerful faction must be expected to prevail. Shall domestic manufactures be encouraged, and in what degree, by restrictions on foreign manufactures? are questions which would be differently decided by the landed and the manufacturing classes, and probably by neither with a sole regard to justice and the public good. The apportionment of taxes on the various descriptions of property is an act which seems to require the most exact impartiality; yet there is, perhaps, no legislative act in which greater opportunity and temptation are given to a predominant party to trample on the rules of justice. Every shilling with which they overburden the inferior number, is a shilling saved to their own pockets.\n\n"
                                 @"It is in vain to say that enlightened statesmen will be able to adjust these clashing interests, and render them all subservient to the public good. Enlightened statesmen will not always be at the helm. Nor, in many cases, can such an adjustment be made at all without taking into view indirect and remote considerations, which will rarely prevail over the immediate interest which one party may find in disregarding the rights of another or the good of the whole.\n\n"
                                 @"The inference to which we are brought is, that the CAUSES of faction cannot be removed, and that relief is only to be sought in the means of controlling its EFFECTS.\n\n"
                                 @"If a faction consists of less than a majority, relief is supplied by the republican principle, which enables the majority to defeat its sinister views by regular vote. It may clog the administration, it may convulse the society; but it will be unable to execute and mask its violence under the forms of the Constitution. When a majority is included in a faction, the form of popular government, on the other hand, enables it to sacrifice to its ruling passion or interest both the public good and the rights of other citizens. To secure the public good and private rights against the danger of such a faction, and at the same time to preserve the spirit and the form of popular government, is then the great object to which our inquiries are directed. Let me add that it is the great desideratum by which this form of government can be rescued from the opprobrium under which it has so long labored, and be recommended to the esteem and adoption of mankind.\n\n"
                                 @"By what means is this object attainable? Evidently by one of two only. Either the existence of the same passion or interest in a majority at the same time must be prevented, or the majority, having such coexistent passion or interest, must be rendered, by their number and local situation, unable to concert and carry into effect schemes of oppression. If the impulse and the opportunity be suffered to coincide, we well know that neither moral nor religious motives can be relied on as an adequate control. They are not found to be such on the injustice and violence of individuals, and lose their efficacy in proportion to the number combined together, that is, in proportion as their efficacy becomes needful.\n\n"
                                 @"From this view of the subject it may be concluded that a pure democracy, by which I mean a society consisting of a small number of citizens, who assemble and administer the government in person, can admit of no cure for the mischiefs of faction. A common passion or interest will, in almost every case, be felt by a majority of the whole; a communication and concert result from the form of government itself; and there is nothing to check the inducements to sacrifice the weaker party or an obnoxious individual. Hence it is that such democracies have ever been spectacles of turbulence and contention; have ever been found incompatible with personal security or the rights of property; and have in general been as short in their lives as they have been violent in their deaths. Theoretic politicians, who have patronized this species of government, have erroneously supposed that by reducing mankind to a perfect equality in their political rights, they would, at the same time, be perfectly equalized and assimilated in their possessions, their opinions, and their passions.\n\n"
                                 @"A republic, by which I mean a government in which the scheme of representation takes place, opens a different prospect, and promises the cure for which we are seeking. Let us examine the points in which it varies from pure democracy, and we shall comprehend both the nature of the cure and the efficacy which it must derive from the Union.\n\n"
                                 @"The two great points of difference between a democracy and a republic are: first, the delegation of the government, in the latter, to a small number of citizens elected by the rest; secondly, the greater number of citizens, and greater sphere of country, over which the latter may be extended.\n\n"
                                 @"The effect of the first difference is, on the one hand, to refine and enlarge the public views, by passing them through the medium of a chosen body of citizens, whose wisdom may best discern the true interest of their country, and whose patriotism and love of justice will be least likely to sacrifice it to temporary or partial considerations. Under such a regulation, it may well happen that the public voice, pronounced by the representatives of the people, will be more consonant to the public good than if pronounced by the people themselves, convened for the purpose. On the other hand, the effect may be inverted. Men of factious tempers, of local prejudices, or of sinister designs, may, by intrigue, by corruption, or by other means, first obtain the suffrages, and then betray the interests, of the people. The question resulting is, whether small or extensive republics are more favorable to the election of proper guardians of the public weal; and it is clearly decided in favor of the latter by two obvious considerations:\n\n"
                                 @"In the first place, it is to be remarked that, however small the republic may be, the representatives must be raised to a certain number, in order to guard against the cabals of a few; and that, however large it may be, they must be limited to a certain number, in order to guard against the confusion of a multitude. Hence, the number of representatives in the two cases not being in proportion to that of the two constituents, and being proportionally greater in the small republic, it follows that, if the proportion of fit characters be not less in the large than in the small republic, the former will present a greater option, and consequently a greater probability of a fit choice.\n\n"
                                 @"In the next place, as each representative will be chosen by a greater number of citizens in the large than in the small republic, it will be more difficult for unworthy candidates to practice with success the vicious arts by which elections are too often carried; and the suffrages of the people being more free, will be more likely to centre in men who possess the most attractive merit and the most diffusive and established characters.\n\n"
                                 @"It must be confessed that in this, as in most other cases, there is a mean, on both sides of which inconveniences will be found to lie. By enlarging too much the number of electors, you render the representatives too little acquainted with all their local circumstances and lesser interests; as by reducing it too much, you render him unduly attached to these, and too little fit to comprehend and pursue great and national objects. The federal Constitution forms a happy combination in this respect; the great and aggregate interests being referred to the national, the local and particular to the State legislatures.\n\n"
                                 @"The other point of difference is, the greater number of citizens and extent of territory which may be brought within the compass of republican than of democratic government; and it is this circumstance principally which renders factious combinations less to be dreaded in the former than in the latter. The smaller the society, the fewer probably will be the distinct parties and interests composing it; the fewer the distinct parties and interests, the more frequently will a majority be found of the same party; and the smaller the number of individuals composing a majority, and the smaller the compass within which they are placed, the more easily will they concert and execute their plans of oppression. Extend the sphere, and you take in a greater variety of parties and interests; you make it less probable that a majority of the whole will have a common motive to invade the rights of other citizens; or if such a common motive exists, it will be more difficult for all who feel it to discover their own strength, and to act in unison with each other. Besides other impediments, it may be remarked that, where there is a consciousness of unjust or dishonorable purposes, communication is always checked by distrust in proportion to the number whose concurrence is necessary.\n\n"
                                 @"Hence, it clearly appears, that the same advantage which a republic has over a democracy, in controlling the effects of faction, is enjoyed by a large over a small republic,--is enjoyed by the Union over the States composing it. Does the advantage consist in the substitution of representatives whose enlightened views and virtuous sentiments render them superior to local prejudices and schemes of injustice? It will not be denied that the representation of the Union will be most likely to possess these requisite endowments. Does it consist in the greater security afforded by a greater variety of parties, against the event of any one party being able to outnumber and oppress the rest? In an equal degree does the increased variety of parties comprised within the Union, increase this security. Does it, in fine, consist in the greater obstacles opposed to the concert and accomplishment of the secret wishes of an unjust and interested majority? Here, again, the extent of the Union gives it the most palpable advantage.\n\n"
                                 @"The influence of factious leaders may kindle a flame within their particular States, but will be unable to spread a general conflagration through the other States. A religious sect may degenerate into a political faction in a part of the Confederacy; but the variety of sects dispersed over the entire face of it must secure the national councils against any danger from that source. A rage for paper money, for an abolition of debts, for an equal division of property, or for any other improper or wicked project, will be less apt to pervade the whole body of the Union than a particular member of it; in the same proportion as such a malady is more likely to taint a particular county or district, than an entire State.\n\n"
                                 @"In the extent and proper structure of the Union, therefore, we behold a republican remedy for the diseases most incident to republican government. And according to the degree of pleasure and pride we feel in being republicans, ought to be our zeal in cherishing the spirit and supporting the character of Federalists."],
                                [Section sectionWithTitle:@"The Utility of the Union in Respect to Commercial Relations and a Navy" text:@"To the People of the State of New York:\n\n"
                                 @"THE importance of the Union, in a commercial light, is one of those points about which there is least room to entertain a difference of opinion, and which has, in fact, commanded the most general assent of men who have any acquaintance with the subject. This applies as well to our intercourse with foreign countries as with each other.\n\n"
                                 @"There are appearances to authorize a supposition that the adventurous spirit, which distinguishes the commercial character of America, has already excited uneasy sensations in several of the maritime powers of Europe. They seem to be apprehensive of our too great interference in that carrying trade, which is the support of their navigation and the foundation of their naval strength. Those of them which have colonies in America look forward to what this country is capable of becoming, with painful solicitude. They foresee the dangers that may threaten their American dominions from the neighborhood of States, which have all the dispositions, and would possess all the means, requisite to the creation of a powerful marine. Impressions of this kind will naturally indicate the policy of fostering divisions among us, and of depriving us, as far as possible, of an ACTIVE COMMERCE in our own bottoms. This would answer the threefold purpose of preventing our interference in their navigation, of monopolizing the profits of our trade, and of clipping the wings by which we might soar to a dangerous greatness. Did not prudence forbid the detail, it would not be difficult to trace, by facts, the workings of this policy to the cabinets of ministers.\n\n"
                                 @"If we continue united, we may counteract a policy so unfriendly to our prosperity in a variety of ways. By prohibitory regulations, extending, at the same time, throughout the States, we may oblige foreign countries to bid against each other, for the privileges of our markets. This assertion will not appear chimerical to those who are able to appreciate the importance of the markets of three millions of people--increasing in rapid progression, for the most part exclusively addicted to agriculture, and likely from local circumstances to remain so--to any manufacturing nation; and the immense difference there would be to the trade and navigation of such a nation, between a direct communication in its own ships, and an indirect conveyance of its products and returns, to and from America, in the ships of another country. Suppose, for instance, we had a government in America, capable of excluding Great Britain (with whom we have at present no treaty of commerce) from all our ports; what would be the probable operation of this step upon her politics? Would it not enable us to negotiate, with the fairest prospect of success, for commercial privileges of the most valuable and extensive kind, in the dominions of that kingdom? When these questions have been asked, upon other occasions, they have received a plausible, but not a solid or satisfactory answer. It has been said that prohibitions on our part would produce no change in the system of Britain, because she could prosecute her trade with us through the medium of the Dutch, who would be her immediate customers and paymasters for those articles which were wanted for the supply of our markets. But would not her navigation be materially injured by the loss of the important advantage of being her own carrier in that trade? Would not the principal part of its profits be intercepted by the Dutch, as a compensation for their agency and risk? Would not the mere circumstance of freight occasion a considerable deduction? Would not so circuitous an intercourse facilitate the competitions of other nations, by enhancing the price of British commodities in our markets, and by transferring to other hands the management of this interesting branch of the British commerce?\n\n"
                                 @"A mature consideration of the objects suggested by these questions will justify a belief that the real disadvantages to Britain from such a state of things, conspiring with the pre-possessions of a great part of the nation in favor of the American trade, and with the importunities of the West India islands, would produce a relaxation in her present system, and would let us into the enjoyment of privileges in the markets of those islands elsewhere, from which our trade would derive the most substantial benefits. Such a point gained from the British government, and which could not be expected without an equivalent in exemptions and immunities in our markets, would be likely to have a correspondent effect on the conduct of other nations, who would not be inclined to see themselves altogether supplanted in our trade.\n\n"
                                 @"A further resource for influencing the conduct of European nations toward us, in this respect, would arise from the establishment of a federal navy. There can be no doubt that the continuance of the Union under an efficient government would put it in our power, at a period not very distant, to create a navy which, if it could not vie with those of the great maritime powers, would at least be of respectable weight if thrown into the scale of either of two contending parties. This would be more peculiarly the case in relation to operations in the West Indies. A few ships of the line, sent opportunely to the reinforcement of either side, would often be sufficient to decide the fate of a campaign, on the event of which interests of the greatest magnitude were suspended. Our position is, in this respect, a most commanding one. And if to this consideration we add that of the usefulness of supplies from this country, in the prosecution of military operations in the West Indies, it will readily be perceived that a situation so favorable would enable us to bargain with great advantage for commercial privileges. A price would be set not only upon our friendship, but upon our neutrality. By a steady adherence to the Union we may hope, erelong, to become the arbiter of Europe in America, and to be able to incline the balance of European competitions in this part of the world as our interest may dictate.\n\n"
                                 @"But in the reverse of this eligible situation, we shall discover that the rivalships of the parts would make them checks upon each other, and would frustrate all the tempting advantages which nature has kindly placed within our reach. In a state so insignificant our commerce would be a prey to the wanton intermeddlings of all nations at war with each other; who, having nothing to fear from us, would with little scruple or remorse, supply their wants by depredations on our property as often as it fell in their way. The rights of neutrality will only be respected when they are defended by an adequate power. A nation, despicable by its weakness, forfeits even the privilege of being neutral.\n\n"
                                 @"Under a vigorous national government, the natural strength and resources of the country, directed to a common interest, would baffle all the combinations of European jealousy to restrain our growth. This situation would even take away the motive to such combinations, by inducing an impracticability of success. An active commerce, an extensive navigation, and a flourishing marine would then be the offspring of moral and physical necessity. We might defy the little arts of the little politicians to control or vary the irresistible and unchangeable course of nature.\n\n"
                                 @"But in a state of disunion, these combinations might exist and might operate with success. It would be in the power of the maritime nations, availing themselves of our universal impotence, to prescribe the conditions of our political existence; and as they have a common interest in being our carriers, and still more in preventing our becoming theirs, they would in all probability combine to embarrass our navigation in such a manner as would in effect destroy it, and confine us to a PASSIVE COMMERCE. We should then be compelled to content ourselves with the first price of our commodities, and to see the profits of our trade snatched from us to enrich our enemies and p rsecutors. That unequaled spirit of enterprise, which signalizes the genius of the American merchants and navigators, and which is in itself an inexhaustible mine of national wealth, would be stifled and lost, and poverty and disgrace would overspread a country which, with wisdom, might make herself the admiration and envy of the world.\n\n"
                                 @"There are rights of great moment to the trade of America which are rights of the Union--I allude to the fisheries, to the navigation of the Western lakes, and to that of the Mississippi. The dissolution of the Confederacy would give room for delicate questions concerning the future existence of these rights; which the interest of more powerful partners would hardly fail to solve to our disadvantage. The disposition of Spain with regard to the Mississippi needs no comment. France and Britain are concerned with us in the fisheries, and view them as of the utmost moment to their navigation. They, of course, would hardly remain long indifferent to that decided mastery, of which experience has shown us to be possessed in this valuable branch of traffic, and by which we are able to undersell those nations in their own markets. What more natural than that they should be disposed to exclude from the lists such dangerous competitors?\n\n"
                                 @"This branch of trade ought not to be considered as a partial benefit. All the navigating States may, in different degrees, advantageously participate in it, and under circumstances of a greater extension of mercantile capital, would not be unlikely to do it. As a nursery of seamen, it now is, or when time shall have more nearly assimilated the principles of navigation in the several States, will become, a universal resource. To the establishment of a navy, it must be indispensable.\n\n"
                                 @"To this great national object, a NAVY, union will contribute in various ways. Every institution will grow and flourish in proportion to the quantity and extent of the means concentred towards its formation and support. A navy of the United States, as it would embrace the resources of all, is an object far less remote than a navy of any single State or partial confederacy, which would only embrace the resources of a single part. It happens, indeed, that different portions of confederated America possess each some peculiar advantage for this essential establishment. The more southern States furnish in greater abundance certain kinds of naval stores--tar, pitch, and turpentine. Their wood for the construction of ships is also of a more solid and lasting texture. The difference in the duration of the ships of which the navy might be composed, if chiefly constructed of Southern wood, would be of signal importance, either in the view of naval strength or of national economy. Some of the Southern and of the Middle States yield a greater plenty of iron, and of better quality. Seamen must chiefly be drawn from the Northern hive. The necessity of naval protection to external or maritime commerce does not require a particular elucidation, no more than the conduciveness of that species of commerce to the prosperity of a navy.\n\n"
                                 @"An unrestrained intercourse between the States themselves will advance the trade of each by an interchange of their respective productions, not only for the supply of reciprocal wants at home, but for exportation to foreign markets. The veins of commerce in every part will be replenished, and will acquire additional motion and vigor from a free circulation of the commodities of every part. Commercial enterprise will have much greater scope, from the diversity in the productions of different States. When the staple of one fails from a bad harvest or unproductive crop, it can call to its aid the staple of another. The variety, not less than the value, of products for exportation contributes to the activity of foreign commerce. It can be conducted upon much better terms with a large number of materials of a given value than with a small number of materials of the same value; arising from the competitions of trade and from the fluctations of markets. Particular articles may be in great demand at certain periods, and unsalable at others; but if there be a variety of articles, it can scarcely happen that they should all be at one time in the latter predicament, and on this account the operations of the merchant would be less liable to any considerable obstruction or stagnation. The speculative trader will at once perceive the force of these observations, and will acknowledge that the aggregate balance of the commerce of the United States would bid fair to be much more favorable than that of the thirteen States without union or with partial unions.\n\n"
                                 @"It may perhaps be replied to this, that whether the States are united or disunited, there would still be an intimate intercourse between them which would answer the same ends; this intercourse would be fettered, interrupted, and narrowed by a multiplicity of causes, which in the course of these papers have been amply detailed. A unity of commercial, as well as political, interests, can only result from a unity of government.\n\n"
                                 @"There are other points of view in which this subject might be placed, of a striking and animating kind. But they would lead us too far into the regions of futurity, and would involve topics not proper for a newspaper discussion. I shall briefly observe, that our situation invites and our interests prompt us to aim at an ascendant in the system of American affairs. The world may politically, as well as geographically, be divided into four parts, each having a distinct set of interests. Unhappily for the other three, Europe, by her arms and by her negotiations, by force and by fraud, has, in different degrees, extended her dominion over them all. Africa, Asia, and America, have successively felt her domination. The superiority she has long maintained has tempted her to plume herself as the Mistress of the World, and to consider the rest of mankind as created for her benefit. Men admired as profound philosophers have, in direct terms, attributed to her inhabitants a physical superiority, and have gravely asserted that all animals, and with them the human species, degenerate in America--that even dogs cease to bark after having breathed awhile in our atmosphere.1 Facts have too long supported these arrogant pretensions of the Europeans. It belongs to us to vindicate the honor of the human race, and to teach that assuming brother, moderation. Union will enable us to do it. Disunion will will add another victim to his triumphs. Let Americans disdain to be the instruments of European greatness! Let the thirteen States, bound together in a strict and indissoluble Union, concur in erecting one great American system, superior to the control of all transatlantic force or influence, and able to dictate the terms of the connection between the old and the new world!"],
                                [Section sectionWithTitle:@"The Utility of the Union In Respect to Revenue" text:@"To the People of the State of New York:\n\n"
                                 @"THE effects of Union upon the commercial prosperity of the States have been sufficiently delineated. Its tendency to promote the interests of revenue will be the subject of our present inquiry.\n\n"
                                 @"The prosperity of commerce is now perceived and acknowledged by all enlightened statesmen to be the most useful as well as the most productive source of national wealth, and has accordingly become a primary object of their political cares. By multipying the means of gratification, by promoting the introduction and circulation of the precious metals, those darling objects of human avarice and enterprise, it serves to vivify and invigorate the channels of industry, and to make them flow with greater activity and copiousness. The assiduous merchant, the laborious husbandman, the active mechanic, and the industrious manufacturer,--all orders of men, look forward with eager expectation and growing alacrity to this pleasing reward of their toils. The often-agitated question between agriculture and commerce has, from indubitable experience, received a decision which has silenced the rivalship that once subsisted between them, and has proved, to the satisfaction of their friends, that their interests are intimately blended and interwoven. It has been found in various countries that, in proportion as commerce has flourished, land has risen in value. And how could it have happened otherwise? Could that which procures a freer vent for the products of the earth, which furnishes new incitements to the cultivation of land, which is the most powerful instrument in increasing the quantity of money in a state--could that, in fine, which is the faithful handmaid of labor and industry, in every shape, fail to augment that article, which is the prolific parent of far the greatest part of the objects upon which they are exerted? It is astonishing that so simple a truth should ever have had an adversary; and it is one, among a multitude of proofs, how apt a spirit of ill-informed jealousy, or of too great abstraction and refinement, is to lead men astray from the plainest truths of reason and conviction.\n\n"
                                 @"The ability of a country to pay taxes must always be proportioned, in a great degree, to the quantity of money in circulation, and to the celerity with which it circulates. Commerce, contributing to both these objects, must of necessity render the payment of taxes easier, and facilitate the requisite supplies to the treasury. The hereditary dominions of the Emperor of Germany contain a great extent of fertile, cultivated, and populous territory, a large proportion of which is situated in mild and luxuriant climates. In some parts of this territory are to be found the best gold and silver mines in Europe. And yet, from the want of the fostering influence of commerce, that monarch can boast but slender revenues. He has several times been compelled to owe obligations to the pecuniary succors of other nations for the preservation of his essential interests, and is unable, upon the strength of his own resources, to sustain a long or continued war.\n\n"
                                 @"But it is not in this aspect of the subject alone that Union will be seen to conduce to the purpose of revenue. There are other points of view, in which its influence will appear more immediate and decisive. It is evident from the state of the country, from the habits of the people, from the experience we have had on the point itself, that it is impracticable to raise any very considerable sums by direct taxation. Tax laws have in vain been multiplied; new methods to enforce the collection have in vain been tried; the public expectation has been uniformly disappointed, and the treasuries of the States have remained empty. The popular system of administration inherent in the nature of popular government, coinciding with the real scarcity of money incident to a languid and mutilated state of trade, has hitherto defeated every experiment for extensive collections, and has at length taught the different legislatures the folly of attempting them.\n\n"
                                 @"No person acquainted with what happens in other countries will be surprised at this circumstance. In so opulent a nation as that of Britain, where direct taxes from superior wealth must be much more tolerable, and, from the vigor of the government, much more practicable, than in America, far the greatest part of the national revenue is derived from taxes of the indirect kind, from imposts, and from excises. Duties on imported articles form a large branch of this latter description.\n\n"
                                 @"In America, it is evident that we must a long time depend for the means of revenue chiefly on such duties. In most parts of it, excises must be confined within a narrow compass. The genius of the people will ill brook the inquisitive and peremptory spirit of excise laws. The pockets of the farmers, on the other hand, will reluctantly yield but scanty supplies, in the unwelcome shape of impositions on their houses and lands; and personal property is too precarious and invisible a fund to be laid hold of in any other way than by the inperceptible agency of taxes on consumption.\n\n"
                                 @"If these remarks have any foundation, that state of things which will best enable us to improve and extend so valuable a resource must be best adapted to our political welfare. And it cannot admit of a serious doubt, that this state of things must rest on the basis of a general Union. As far as this would be conducive to the interests of commerce, so far it must tend to the extension of the revenue to be drawn from that source. As far as it would contribute to rendering regulations for the collection of the duties more simple and efficacious, so far it must serve to answer the purposes of making the same rate of duties more productive, and of putting it into the power of the government to increase the rate without prejudice to trade.\n\n"
                                 @"The relative situation of these States; the number of rivers with which they are intersected, and of bays that wash there shores; the facility of communication in every direction; the affinity of language and manners; the familiar habits of intercourse; --all these are circumstances that would conspire to render an illicit trade between them a matter of little difficulty, and would insure frequent evasions of the commercial regulations of each other. The separate States or confederacies would be necessitated by mutual jealousy to avoid the temptations to that kind of trade by the lowness of their duties. The temper of our governments, for a long time to come, would not permit those rigorous precautions by which the European nations guard the avenues into their respective countries, as well by land as by water; and which, even there, are found insufficient obstacles to the adventurous stratagems of avarice.\n\n"
                                 @"In France, there is an army of patrols (as they are called) constantly employed to secure their fiscal regulations against the inroads of the dealers in contraband trade. Mr. Neckar computes the number of these patrols at upwards of twenty thousand. This shows the immense difficulty in preventing that species of traffic, where there is an inland communication, and places in a strong light the disadvantages with which the collection of duties in this country would be encumbered, if by disunion the States should be placed in a situation, with respect to each other, resembling that of France with respect to her neighbors. The arbitrary and vexatious powers with which the patrols are necessarily armed, would be intolerable in a free country.\n\n"
                                 @"If, on the contrary, there be but one government pervading all the States, there will be, as to the principal part of our commerce, but ONE SIDE to guard--the ATLANTIC COAST. Vessels arriving directly from foreign countries, laden with valuable cargoes, would rarely choose to hazard themselves to the complicated and critical perils which would attend attempts to unlade prior to their coming into port. They would have to dread both the dangers of the coast, and of detection, as well after as before their arrival at the places of their final destination. An ordinary degree of vigilance would be competent to the prevention of any material infractions upon the rights of the revenue. A few armed vessels, judiciously stationed at the entrances of our ports, might at a small expense be made useful sentinels of the laws. And the government having the same interest to provide against violations everywhere, the co-operation of its measures in each State would have a powerful tendency to render them effectual. Here also we should preserve by Union, an advantage which nature holds out to us, and which would be relinquished by separation. The United States lie at a great distance from Europe, and at a considerable distance from all other places with which they would have extensive connections of foreign trade. The passage from them to us, in a few hours, or in a single night, as between the coasts of France and Britain, and of other neighboring nations, would be impracticable. This is a prodigious security against a direct contraband with foreign countries; but a circuitous contraband to one State, through the medium of another, would be both easy and safe. The difference between a direct importation from abroad, and an indirect importation through the channel of a neighboring State, in small parcels, according to time and opportunity, with the additional facilities of inland communication, must be palpable to every man of discernment.\n\n"
                                 @"It is therefore evident, that one national government would be able, at much less expense, to extend the duties on imports, beyond comparison, further than would be practicable to the States separately, or to any partial confederacies. Hitherto, I believe, it may safely be asserted, that these duties have not upon an average exceeded in any State three per cent. In France they are estimated to be about fifteen per cent., and in Britain they exceed this proportion.1 There seems to be nothing to hinder their being increased in this country to at least treble their present amount. The single article of ardent spirits, under federal regulation, might be made to furnish a considerable revenue. Upon a ratio to the importation into this State, the whole quantity imported into the United States may be estimated at four millions of gallons; which, at a shilling per gallon, would produce two hundred thousand pounds. That article would well bear this rate of duty; and if it should tend to diminish the consumption of it, such an effect would be equally favorable to the agriculture, to the economy, to the morals, and to the health of the society. There is, perhaps, nothing so much a subject of national extravagance as these spirits.\n\n"
                                 @"What will be the consequence, if we are not able to avail ourselves of the resource in question in its full extent? A nation cannot long exist without revenues. Destitute of this essential support, it must resign its independence, and sink into the degraded condition of a province. This is an extremity to which no government will of choice accede. Revenue, therefore, must be had at all events. In this country, if the principal part be not drawn from commerce, it must fall with oppressive weight upon land. It has been already intimated that excises, in their true signification, are too little in unison with the feelings of the people, to admit of great use being made of that mode of taxation; nor, indeed, in the States where almost the sole employment is agriculture, are the objects proper for excise sufficiently numerous to permit very ample collections in that way. Personal estate (as has been before remarked), from the difficulty in tracing it, cannot be subjected to large contributions, by any other means than by taxes on consumption. In populous cities, it may be enough the subject of conjecture, to occasion the oppression of individuals, without much aggregate benefit to the State; but beyond these circles, it must, in a great measure, escape the eye and the hand of the tax-gatherer. As the necessities of the State, nevertheless, must be satisfied in some mode or other, the defect of other resources must throw the principal weight of public burdens on the possessors of land. And as, on the other hand, the wants of the government can never obtain an adequate supply, unless all the sources of revenue are open to its demands, the finances of the community, under such embarrassments, cannot be put into a situation consistent with its respectability or its security. Thus we shall not even have the consolations of a full treasury, to atone for the oppression of that valuable class of the citizens who are employed in the cultivation of the soil. But public and private distress will keep pace with each other in gloomy concert; and unite in deploring the infatuation of those counsels which led to disunion."],
                                [Section sectionWithTitle:@"Advantage of the Union in Respect to Economy in Government" text:@"To the People of the State of New York:\n\n"
                                 @"As CONNECTED with the subject of revenue, we may with propriety consider that of economy. The money saved from one object may be usefully applied to another, and there will be so much the less to be drawn from the pockets of the people. If the States are united under one government, there will be but one national civil list to support; if they are divided into several confederacies, there will be as many different national civil lists to be provided for--and each of them, as to the principal departments, coextensive with that which would be necessary for a government of the whole. The entire separation of the States into thirteen unconnected sovereignties is a project too extravagant and too replete with danger to have many advocates. The ideas of men who speculate upon the dismemberment of the empire seem generally turned toward three confederacies--one consisting of the four Northern, another of the four Middle, and a third of the five Southern States. There is little probability that there would be a greater number. According to this distribution, each confederacy would comprise an extent of territory larger than that of the kingdom of Great Britain. No well-informed man will suppose that the affairs of such a confederacy can be properly regulated by a government less comprehensive in its organs or institutions than that which has been proposed by the convention. When the dimensions of a State attain to a certain magnitude, it requires the same energy of government and the same forms of administration which are requisite in one of much greater extent. This idea admits not of precise demonstration, because there is no rule by which we can measure the momentum of civil power necessary to the government of any given number of individuals; but when we consider that the island of Britain, nearly commensurate with each of the supposed confederacies, contains about eight millions of people, and when we reflect upon the degree of authority required to direct the passions of so large a society to the public good, we shall see no reason to doubt that the like portion of power would be sufficient to perform the same task in a society far more numerous. Civil power, properly organized and exerted, is capable of diffusing its force to a very great extent; and can, in a manner, reproduce itself in every part of a great empire by a judicious arrangement of subordinate institutions.\n\n"
                                 @"The supposition that each confederacy into which the States would be likely to be divided would require a government not less comprehensive than the one proposed, will be strengthened by another supposition, more probable than that which presents us with three confederacies as the alternative to a general Union. If we attend carefully to geographical and commercial considerations, in conjunction with the habits and prejudices of the different States, we shall be led to conclude that in case of disunion they will most naturally league themselves under two governments. The four Eastern States, from all the causes that form the links of national sympathy and connection, may with certainty be expected to unite. New York, situated as she is, would never be unwise enough to oppose a feeble and unsupported flank to the weight of that confederacy. There are other obvious reasons that would facilitate her accession to it. New Jersey is too small a State to think of being a frontier, in opposition to this still more powerful combination; nor do there appear to be any obstacles to her admission into it. Even Pennsylvania would have strong inducements to join the Northern league. An active foreign commerce, on the basis of her own navigation, is her true policy, and coincides with the opinions and dispositions of her citizens. The more Southern States, from various circumstances, may not think themselves much interested in the encouragement of navigation. They may prefer a system which would give unlimited scope to all nations to be the carriers as well as the purchasers of their commodities. Pennsylvania may not choose to confound her interests in a connection so adverse to her policy. As she must at all events be a frontier, she may deem it most consistent with her safety to have her exposed side turned towards the weaker power of the Southern, rather than towards the stronger power of the Northern, Confederacy. This would give her the fairest chance to avoid being the Flanders of America. Whatever may be the determination of Pennsylvania, if the Northern Confederacy includes New Jersey, there is no likelihood of more than one confederacy to the south of that State.\n\n"
                                 @"Nothing can be more evident than that the thirteen States will be able to support a national government better than one half, or one third, or any number less than the whole. This reflection must have great weight in obviating that objection to the proposed plan, which is founded on the principle of expense; an objection, however, which, when we come to take a nearer view of it, will appear in every light to stand on mistaken ground.\n\n"
                                 @"If, in addition to the consideration of a plurality of civil lists, we take into view the number of persons who must necessarily be employed to guard the inland communication between the different confederacies against illicit trade, and who in time will infallibly spring up out of the necessities of revenue; and if we also take into view the military establishments which it has been shown would unavoidably result from the jealousies and conflicts of the several nations into which the States would be divided, we shall clearly discover that a separation would be not less injurious to the economy, than to the tranquillity, commerce, revenue, and liberty of every part."],
                                [Section sectionWithTitle:@"Objections to the Proposed Constitution From Extent of Territory Answered" text:@"To the People of the State of New York:\n\n"
                                 @"WE HAVE seen the necessity of the Union, as our bulwark against foreign danger, as the conservator of peace among ourselves, as the guardian of our commerce and other common interests, as the only substitute for those military establishments which have subverted the liberties of the Old World, and as the proper antidote for the diseases of faction, which have proved fatal to other popular governments, and of which alarming symptoms have been betrayed by our own. All that remains, within this branch of our inquiries, is to take notice of an objection that may be drawn from the great extent of country which the Union embraces. A few observations on this subject will be the more proper, as it is perceived that the adversaries of the new Constitution are availing themselves of the prevailing prejudice with regard to the practicable sphere of republican administration, in order to supply, by imaginary difficulties, the want of those solid objections which they endeavor in vain to find.\n\n"
                                 @"The error which limits republican government to a narrow district has been unfolded and refuted in preceding papers. I remark here only that it seems to owe its rise and prevalence chiefly to the confounding of a republic with a democracy, applying to the former reasonings drawn from the nature of the latter. The true distinction between these forms was also adverted to on a former occasion. It is, that in a democracy, the people meet and exercise the government in person; in a republic, they assemble and administer it by their representatives and agents. A democracy, consequently, will be confined to a small spot. A republic may be extended over a large region.\n\n"
                                 @"To this accidental source of the error may be added the artifice of some celebrated authors, whose writings have had a great share in forming the modern standard of political opinions. Being subjects either of an absolute or limited monarchy, they have endeavored to heighten the advantages, or palliate the evils of those forms, by placing in comparison the vices and defects of the republican, and by citing as specimens of the latter the turbulent democracies of ancient Greece and modern Italy. Under the confusion of names, it has been an easy task to transfer to a republic observations applicable to a democracy only; and among others, the observation that it can never be established but among a small number of people, living within a small compass of territory.\n\n"
                                 @"Such a fallacy may have been the less perceived, as most of the popular governments of antiquity were of the democratic species; and even in modern Europe, to which we owe the great principle of representation, no example is seen of a government wholly popular, and founded, at the same time, wholly on that principle. If Europe has the merit of discovering this great mechanical power in government, by the simple agency of which the will of the largest political body may be concentred, and its force directed to any object which the public good requires, America can claim the merit of making the discovery the basis of unmixed and extensive republics. It is only to be lamented that any of her citizens should wish to deprive her of the additional merit of displaying its full efficacy in the establishment of the comprehensive system now under her consideration.\n\n"
                                 @"As the natural limit of a democracy is that distance from the central point which will just permit the most remote citizens to assemble as often as their public functions demand, and will include no greater number than can join in those functions; so the natural limit of a republic is that distance from the centre which will barely allow the representatives to meet as often as may be necessary for the administration of public affairs. Can it be said that the limits of the United States exceed this distance? It will not be said by those who recollect that the Atlantic coast is the longest side of the Union, that during the term of thirteen years, the representatives of the States have been almost continually assembled, and that the members from the most distant States are not chargeable with greater intermissions of attendance than those from the States in the neighborhood of Congress.\n\n"
                                 @"That we may form a juster estimate with regard to this interesting subject, let us resort to the actual dimensions of the Union. The limits, as fixed by the treaty of peace, are: on the east the Atlantic, on the south the latitude of thirty-one degrees, on the west the Mississippi, and on the north an irregular line running in some instances beyond the forty-fifth degree, in others falling as low as the forty-second. The southern shore of Lake Erie lies below that latitude. Computing the distance between the thirty-first and forty-fifth degrees, it amounts to nine hundred and seventy-three common miles; computing it from thirty-one to forty-two degrees, to seven hundred and sixty-four miles and a half. Taking the mean for the distance, the amount will be eight hundred and sixty-eight miles and three-fourths. The mean distance from the Atlantic to the Mississippi does not probably exceed seven hundred and fifty miles. On a comparison of this extent with that of several countries in Europe, the practicability of rendering our system commensurate to it appears to be demonstrable. It is not a great deal larger than Germany, where a diet representing the whole empire is continually assembled; or than Poland before the late dismemberment, where another national diet was the depositary of the supreme power. Passing by France and Spain, we find that in Great Britain, inferior as it may be in size, the representatives of the northern extremity of the island have as far to travel to the national council as will be required of those of the most remote parts of the Union.\n\n"
                                 @"Favorable as this view of the subject may be, some observations remain which will place it in a light still more satisfactory.\n\n"
                                 @"In the first place it is to be remembered that the general government is not to be charged with the whole power of making and administering laws. Its jurisdiction is limited to certain enumerated objects, which concern all the members of the republic, but which are not to be attained by the separate provisions of any. The subordinate governments, which can extend their care to all those other subjects which can be separately provided for, will retain their due authority and activity. Were it proposed by the plan of the convention to abolish the governments of the particular States, its adversaries would have some ground for their objection; though it would not be difficult to show that if they were abolished the general government would be compelled, by the principle of self-preservation, to reinstate them in their proper jurisdiction.\n\n"
                                 @"A second observation to be made is that the immediate object of the federal Constitution is to secure the union of the thirteen primitive States, which we know to be practicable; and to add to them such other States as may arise in their own bosoms, or in their neighborhoods, which we cannot doubt to be equally practicable. The arrangements that may be necessary for those angles and fractions of our territory which lie on our northwestern frontier, must be left to those whom further discoveries and experience will render more equal to the task.\n\n"
                                 @"Let it be remarked, in the third place, that the intercourse throughout the Union will be facilitated by new improvements. Roads will everywhere be shortened, and kept in better order; accommodations for travelers will be multiplied and meliorated; an interior navigation on our eastern side will be opened throughout, or nearly throughout, the whole extent of the thirteen States. The communication between the Western and Atlantic districts, and between different parts of each, will be rendered more and more easy by those numerous canals with which the beneficence of nature has intersected our country, and which art finds it so little difficult to connect and complete.\n\n"
                                 @"A fourth and still more important consideration is, that as almost every State will, on one side or other, be a frontier, and will thus find, in regard to its safety, an inducement to make some sacrifices for the sake of the general protection; so the States which lie at the greatest distance from the heart of the Union, and which, of course, may partake least of the ordinary circulation of its benefits, will be at the same time immediately contiguous to foreign nations, and will consequently stand, on particular occasions, in greatest need of its strength and resources. It may be inconvenient for Georgia, or the States forming our western or northeastern borders, to send their representatives to the seat of government; but they would find it more so to struggle alone against an invading enemy, or even to support alone the whole expense of those precautions which may be dictated by the neighborhood of continual danger. If they should derive less benefit, therefore, from the Union in some respects than the less distant States, they will derive greater benefit from it in other respects, and thus the proper equilibrium will be maintained throughout.\n\n"
                                 @"I submit to you, my fellow-citizens, these considerations, in full confidence that the good sense which has so often marked your decisions will allow them their due weight and effect; and that you will never suffer difficulties, however formidable in appearance, or however fashionable the error on which they may be founded, to drive you into the gloomy and perilous scene into which the advocates for disunion would conduct you. Hearken not to the unnatural voice which tells you that the people of America, knit together as they are by so many cords of affection, can no longer live together as members of the same family; can no longer continue the mutual guardians of their mutual happiness; can no longer be fellowcitizens of one great, respectable, and flourishing empire. Hearken not to the voice which petulantly tells you that the form of government recommended for your adoption is a novelty in the political world; that it has never yet had a place in the theories of the wildest projectors; that it rashly attempts what it is impossible to accomplish. No, my countrymen, shut your ears against this unhallowed language. Shut your hearts against the poison which it conveys; the kindred blood which flows in the veins of American citizens, the mingled blood which they have shed in defense of their sacred rights, consecrate their Union, and excite horror at the idea of their becoming aliens, rivals, enemies. And if novelties are to be shunned, believe me, the most alarming of all novelties, the most wild of all projects, the most rash of all attempts, is that of rendering us in pieces, in order to preserve our liberties and promote our happiness. But why is the experiment of an extended republic to be rejected, merely because it may comprise what is new? Is it not the glory of the people of America, that, whilst they have paid a decent regard to the opinions of former times and other nations, they have not suffered a blind veneration for antiquity, for custom, or for names, to overrule the suggestions of their own good sense, the knowledge of their own situation, and the lessons of their own experience? To this manly spirit, posterity will be indebted for the possession, and the world for the example, of the numerous innovations displayed on the American theatre, in favor of private rights and public happiness. Had no important step been taken by the leaders of the Revolution for which a precedent could not be discovered, no government established of which an exact model did not present itself, the people of the United States might, at this moment have been numbered among the melancholy victims of misguided councils, must at best have been laboring under the weight of some of those forms which have crushed the liberties of the rest of mankind. Happily for America, happily, we trust, for the whole human race, they pursued a new and more noble course. They accomplished a revolution which has no parallel in the annals of human society. They reared the fabrics of governments which have no model on the face of the globe. They formed the design of a great Confederacy, which it is incumbent on their successors to improve and perpetuate. If their works betray imperfections, we wonder at the fewness of them. If they erred most in the structure of the Union, this was the work most difficult to be executed; this is the work which has been new modelled by the act of your convention, and it is that act on which you are now to deliberate and to decide."],
                                nil]],
     [Article articleWithTitle:NSLocalizedString(@"Defects of the Articles of Confederation", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]],
     [Article articleWithTitle:NSLocalizedString(@"Arguments for the Constitution", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]],
     [Article articleWithTitle:NSLocalizedString(@"Republican Form of Government", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]],
     [Article articleWithTitle:NSLocalizedString(@"The Legislative Branch", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]],
     [Article articleWithTitle:NSLocalizedString(@"The Executive Branch", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]],
     [Article articleWithTitle:NSLocalizedString(@"The Judicial Branch", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]],
     [Article articleWithTitle:NSLocalizedString(@"Conclusions", nil)
                          link:nil
                      sections:[NSArray arrayWithObjects:nil]], nil];
    
    MultiDictionary* signers = [MultiDictionary dictionary];
    
    federalistPapers = 
    [[Constitution constitutionWithCountry:country
                                  preamble:@""
                                  articles:articles
                                amendments:[NSArray array]
                                conclusion:@""
                                   signers:signers] retain];
}


+ (void) initialize {
    if (self == [Model class]) {
        [self setupToughQuestions];
        [self setupConstitutions];
        [self setupDeclarationOfIndependence];
        [self setupArticlesOfConfederation];
        [self setupFederalistPapers];
        
        sectionTitles = [[NSArray arrayWithObjects:
                          NSLocalizedString(@"Questioning", nil),
                          NSLocalizedString(@"Stops and Arrests", nil),
                          NSLocalizedString(@"Searches and Warrants", nil),
                          NSLocalizedString(@"Additional Information for Non-Citizens", nil),
                          NSLocalizedString(@"Rights at Airports and Other Ports of Entry into the United States", nil),
                          NSLocalizedString(@"Charitable Donations and Religious Practices", nil), nil] retain];
        
        shortSectionTitles = [[NSArray arrayWithObjects:
                               NSLocalizedString(@"Questioning", nil),
                               NSLocalizedString(@"Stops and Arrests", nil),
                               NSLocalizedString(@"Searches and Warrants", nil),
                               NSLocalizedString(@"Info for Non-Citizens", nil),
                               NSLocalizedString(@"Rights at Airports", nil),
                               NSLocalizedString(@"Charitable Donations", nil), nil] retain];
        
        
        preambles = [[NSArray arrayWithObjects:
                      @"",
                      @"",
                      @"",
                      NSLocalizedString(@"In the United States, non-citizens are persons who do not have U.S. "
                                        @"citizenship, including lawful permanent residents, refugees and asylum "
                                        @"seekers, persons who have permission to come to the U.S. for reasons "
                                        @"like work, school or travel, and those without legal immigration status of "
                                        @"any kind. Non-citizens who are in the United States-no matter what "
                                        @"their immigration status-generally have the same constitutional rights "
                                        @"as citizens when law enforcement officers stop, question, arrest, or "
                                        @"search them or their homes. However, there are some special concerns "
                                        @"that apply to non-citizens, so the following rights and responsibilities are "
                                        @"important for non-citizens to know. Non-citizens at the border who are "
                                        @"trying to enter the U.S. do not have all the same rights. See Section 5 for "
                                        @"more information if you are arriving in the U.S.", nil),
                      NSLocalizedString(@"Remember: It is illegal for law enforcement officers to perform any stops, "
                                        @"searches, detentions or removals based solely on your race, national origin, "
                                        @"religion, sex or ethnicity. However, Customs and Border Protection officials "
                                        @"can stop you based on citizenship or travel itinerary at the border and search "
                                        @"all bags.", nil),
                      @"", nil] retain];
        
        otherResources = [[NSArray arrayWithObjects:
                           [NSArray array],
                           [NSArray array],
                           [NSArray array],
                           [NSArray array],
                           [NSArray arrayWithObjects:
                            NSLocalizedString(@"DHS Office for Civil Rights and Civil Liberties\n"
                                              @"http://www.dhs.gov/xabout/structure/editorial_0373.shtm "
                                              @"Investigates abuses of civil rights, civil liberties, and profiling "
                                              @"on the basis of race, ethnicity, or religion by employees and "
                                              @"officials of the Department of Homeland Security. You can submit "
                                              @"your complaint via email to civil.liberties@dhs.gov.", nil),
                            NSLocalizedString(@"U.S. Department of Transportation's Aviation Consumer Protected Division\n"
                                              @"http://airconsumer.ost.dot.gov/problems.htm "
                                              @"Handles complaints against the airline for mistreatment by air "
                                              @"carrier personnel (check-in, gate staff, plane staff, pilot), "
                                              @"including discrimination on the basis of race, ethnicity, religion, "
                                              @"sex, national origin, ancestry, or disability. You can submit a "
                                              @"complaint via email to airconsumer@ost.dot.gov-see the webpage "
                                              @"page for what information to include.", nil),
                            NSLocalizedString(@"U.S. Department of Transportation's Aviation Consumer Protected Division Resource Page\n"
                                              @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm "
                                              @"Provides information about how and where to file complaints "
                                              @"about discriminatory treatment by air carrier personnel, federal "
                                              @"security screeners (e.g., personnel screening and searching "
                                              @"passengers and carry-on baggage at airport security checkpoints), "
                                              @"airport personnel (e.g., airport police), FBI, "
                                              @"Immigration and Customs Enforcement (ICE), U.S. Border "
                                              @"Patrol, Customs and Border Protection, and National Guard.", nil), nil],
                           [NSArray array], nil] retain];
        
        sectionLinks = [[NSArray arrayWithObjects:
                         [NSArray array],
                         [NSArray array],
                         [NSArray array],
                         [NSArray array],
                         [NSArray arrayWithObjects:
                          @"http://www.dhs.gov/xabout/structure/editorial_0373.shtm",
                          @"civil.liberties@dhs.gov",
                          @"http://airconsumer.ost.dot.gov/problems.htm",
                          @"airconsumer@ost.dot.gov",
                          @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm", nil],
                         [NSArray array], nil] retain];
        
        NSArray* questioningQuestions =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What kind of law enforcement officers might try to question me?", nil),
         NSLocalizedString(@"Do I have to answer questions asked by law  enforcement officers?", nil),
         NSLocalizedString(@"Are there any exceptions to the general rule that I do not have to answer questions?", nil),
         NSLocalizedString(@"Can I talk to a lawyer before answering questions?", nil),
         NSLocalizedString(@"What if I speak to law enforcement officers anyway?", nil),
         NSLocalizedString(@"What if law enforcement officers threaten me with a grand "
                           @"jury subpoena if I don’t answer their questions?  (A grand jury "
                           @"subpoena is a written order for youabout information you may have.)", nil),
         NSLocalizedString(@"What if I am asked to meet with officers for a "
                           @"“counter-terrorism interview”?", nil), nil];
        
        NSArray* questioningAnswers =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"You could be questioned by a variety of law enforcement "
                           @"officers, including state or local police officers, Joint Terrorism "
                           @"Task Force members, or federal agents from the FBI, "
                           @"Department of Homeland Security (which includes "
                           @"Immigration and Customs Enforcement and the Border "
                           @"Patrol), Drug Enforcement Administration, Naval Criminal "
                           @"Investigative Service, or other agencies.", nil),
         NSLocalizedString(@"No. You have the constitutional right to remain silent. In "
                           @"general, you do not have to talk to law enforcement officers (or "
                           @"anyone else), even if you do not feel free to walk away from the "
                           @"officer, you are arrested, or you are in jail. You cannot be punished "
                           @"for refusing to answer a question. It is a good idea to "
                           @"talk to a lawyer before agreeing to answer questions. In general, "
                           @"only a judge can order you to answer questions. "
                           @"(Non-citizens should see Section 4 for more information on "
                           @"this topic.)", nil),
         NSLocalizedString(@"Yes, there are two limited exceptions. First, in some states, "
                           @"you must provide your name to law enforcement officers if you "
                           @"are stopped and told to identify yourself. But even if you give "
                           @"your name, you are not required to answer other questions. "
                           @"Second, if you are driving and you are pulled over for a traffic "
                           @"violation, the officer can require you to show your license, "
                           @"vehicle registration and proof of insurance (but you do not "
                           @"have to answer questions). (Non-citizens should see Section 4 "
                           @"for more information on this topic.)", nil),
         NSLocalizedString(@"Yes. You have the constitutional right to talk to a lawyer "
                           @"before answering questions, whether or not the police tell you "
                           @"about that right. The lawyer’s job is to protect your rights. "
                           @"Once you say that you want to talk to a lawyer, officers should "
                           @"stop asking you questions. If they continue to ask questions, "
                           @"you still have the right to remain silent. If you do not have a "
                           @"lawyer, you may still tell the officer you want to speak to one before "
                           @"answering questions. If you do have a lawyer, keep his or her business "
                           @"card with you. Show it to the officer, and ask to call your lawyer. "
                           @"Remember to get the name, agency and telephone number of any law "
                           @"enforcement officer who stops or visits you, and give that information to "
                           @"your lawyer.", nil),
         NSLocalizedString(@"Anything you say to a law enforcement officer can be used against you "
                           @"and others. Keep in mind that lying to a government official is a crime "
                           @"but remaining silent until you consult with a lawyer is not. Even if you "
                           @"have already answered some questions, you can refuse to answer other "
                           @"questions until you have a lawyer.", nil),
         NSLocalizedString(@"If a law enforcement officer threatens to get a subpoena, you still do "
                           @"not have to answer the officer’s questions right then and there, and anything "
                           @"you do say can be used against you. The officer may or may not "
                           @"succeed in getting the subpoena. If you receive a subpoena or an officer "
                           @"threatens to get one for you, you should call a lawyer right away. If you "
                           @"are given a subpoena, you must follow the subpoena’s direction about "
                           @"when and where to report to the court, but you can still assert your right "
                           @"not to say anything that could be used against you in a criminal case.", nil),
         NSLocalizedString(@"You have the right to say that you do not want to be interviewed, to "
                           @"have an attorney present, to set the time and place for the interview, to "
                           @"find out the questions they will ask beforehand, and to answer only the "
                           @"questions you feel comfortable answering. If you are taken into custody "
                           @"for any reason, you have the right to remain silent. No matter what, "
                           @"assume that nothing you say is off the record. And remember that it is a "
                           @"criminal offense to knowingly lie to an officer.", nil), nil];
        
        NSArray* stopsAndArrestsQuestions =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What if law enforcement officers stop me on the street?", nil),
         NSLocalizedString(@"What if law enforcement officers stop me in my car?", nil),
         NSLocalizedString(@"What should I do if law enforcement officers arrest me?", nil),
         NSLocalizedString(@"Do I have to answer questions if I have been arrested?", nil),
         NSLocalizedString(@"What if I am treated badly by law enforcement officers?", nil), nil];
        
        NSArray* stopsAndArrestsAnswers =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"You do not have to answer any questions. You can say, “I do "
                           @"not want to talk to you” and walk away calmly. Or, if you do not "
                           @"feel comfortable doing that, you can ask if you are free to go. If "
                           @"the answer is yes, you can consider just walking away. Do not "
                           @"run from the officer. If the officer says you are not under "
                           @"arrest, but you are not free to go, then you are being detained. "
                           @"Being detained is not the same as being arrested, though an "
                           @"arrest could follow. The police can pat down the outside of "
                           @"your clothing only if they have “reasonable suspicion” (i.e., an "
                           @"objective reason to suspect) that you might be armed and dangerous. "
                           @"If they search any more than this, say clearly, “I do not "
                           @"consent to a search.” If they keep searching anyway, do not "
                           @"physically resist them. You do not need to answer any questions "
                           @"if you are detained or arrested, except that the police may ask "
                           @"for your name once you have been detained, and you can be "
                           @"arrested in some states for refusing to provide it. (Non-citizens "
                           @"should see Section 4 for more information on this topic.)", nil),
         NSLocalizedString(@"Keep your hands where the police can see them. You must "
                           @"show your drivers license, registration and proof of insurance "
                           @"if you are asked for these documents. Officers can also ask "
                           @"you to step outside of the car, and they may separate passengers "
                           @"and drivers from each other to question them and "
                           @"compare their answers, but no one has to answer any questions. "
                           @"The police cannot search your car unless you give them "
                           @"your consent, which you do not have to give, or unless they "
                           @"have “probable cause” to believe (i.e., knowledge of facts sufficient "
                           @"to support a reasonable belief) that criminal activity is "
                           @"likely taking place, that you have been involved in a crime, or "
                           @"that you have evidence of a crime in your car. If you do not "
                           @"want your car searched, clearly state that you do not consent. "
                           @"The officer cannot use your refusal to give consent as a basis "
                           @"for doing a search.", nil),
         NSLocalizedString(@"The officer must advise you of your constitutional rights to "
                           @"remain silent, to an attorney, and to have an attorney appointed "
                           @"if you cannot afford one. You should exercise all these "
                           @"rights, even if the officers don’t tell you about them. Do not tell "
                           @"the police anything except your name. Anything else you say can and will "
                           @"be used against you. Ask to see a lawyer immediately. Within a reasonable "
                           @"amount of time after your arrest or booking you have the right to a "
                           @"phone call. Law enforcement officers may not listen to a call you make "
                           @"to your lawyer, but they can listen to calls you make to other people. You "
                           @"must be taken before a judge as soon as possible-generally within 48 "
                           @"hours of your arrest at the latest.  (See Section 4 for information about "
                           @"arrests for noncriminal immigration violations.)", nil),
         NSLocalizedString(@"No. If you are arrested, you do not have to answer any questions or "
                           @"volunteer any information. Ask for a lawyer right away. Repeat this "
                           @"request to every officer who tries to talk to or question you. You should "
                           @"always talk to a lawyer before you decide to answer any questions.", nil),
         NSLocalizedString(@"Write down the officer’s badge number, name or other identifying "
                           @"information. You have a right to ask the officer for this information. Try to "
                           @"find witnesses and their names and phone numbers. If you are injured, "
                           @"seek medical attention and take pictures of the injuries as soon as you "
                           @"can. Call a lawyer or contact your local ACLU office. You should also "
                           @"make a complaint to the law enforcement office responsible for the "
                           @"treatment.", nil), nil];
        
        
        NSArray* searchesAndWarrantsQuestions =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Can law enforcement officers search my home or office?", nil),
         NSLocalizedString(@"What are warrants and what should I make sure they say?", nil),
         NSLocalizedString(@"What should I do if officers come to my house?", nil),
         NSLocalizedString(@"Do I have to answer questions if law enforcement officers have a search or arrest warrant?", nil),
         NSLocalizedString(@"What if law enforcement officers do not have a search warrant?", nil),
         NSLocalizedString(@"What if law enforcement officers tell me they will come back "
                           @"with a search warrant if I do not let them in?", nil),
         NSLocalizedString(@"What if law enforcement officers do not have a search "
                           @"warrant, but they insist on searching my home even "
                           @"after I object?", nil), nil];
        
        NSArray* searchesAndWarrantsAnswers =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Law enforcement officers can search your home only if they "
                           @"have a warrant or your consent. In your absence, the police can "
                           @"search your home based on the consent of your roommate or a "
                           @"guest if the police reasonably believe that person has the "
                           @"authority to consent. Law enforcement officers can search your "
                           @"office only if they have a warrant or the consent of the employer. "
                           @"If your employer consents to a search of your office, law "
                           @"enforcement officers can search your workspace whether you "
                           @"consent or not.", nil),
         NSLocalizedString(@"A warrant is a piece of paper signed by a judge giving law "
                           @"enforcement officers permission to enter a home or other "
                           @"building to do a search or make an arrest. A search warrant "
                           @"allows law enforcement officers to enter the place described in "
                           @"the warrant to look for and take items identified in the warrant. "
                           @"An arrest warrant allows law enforcement officers to take you "
                           @"into custody. An arrest warrant alone does not give law "
                           @"enforcement officers the right to search your home (but they "
                           @"can look in places where you might be hiding and they can take "
                           @"evidence that is in plain sight), and a search warrant alone "
                           @"does not give them the right to arrest you (but they can arrest "
                           @"you if they find enough evidence to justify an arrest). A warrant "
                           @"must contain the judge’s name, your name and address, the "
                           @"date, place to be searched, a description of any items being "
                           @"searched for, and the name of the agency that is conducting "
                           @"the search or arrest. An arrest warrant that does not have your "
                           @"name on it may still be validly used for your arrest if it "
                           @"describes you with enough detail to identify you, and a search "
                           @"warrant that does not have your name on it may still be valid if "
                           @"it gives the correct address and description of the place the "
                           @"officers will be searching. However, the fact that a piece of "
                           @"paper says “warrant” on it does not always mean that it is an "
                           @"arrest or search warrant. A warrant of deportation/removal, "
                           @"for example, is a kind of administrativewarrant and doesnot "
                           @"grant the same authority to enter a home or other building to "
                           @"do a search or make an arrest.", nil),
         NSLocalizedString(@"If law enforcement officers knock on your door, instead of opening "
                           @"the door, ask through the door if they have a warrant. If the answer is "
                           @"no, do not let them into your home and do not answer any questions or "
                           @"say anything other than “I do not want to talk to you.” If the officers say "
                           @"that they do have a warrant, ask the officers to slip it under the door (or "
                           @"show it to you through a peephole, a window in your door, or a door that "
                           @"is open only enough to see the warrant). If you feel you must open the "
                           @"door, then step outside, close the door behind you and ask to see the "
                           @"warrant. Make sure the search warrant contains everything noted above, "
                           @"and tell the officers if they are at the wrong address or if you see some "
                           @"other mistake in the warrant. (And remember that an immigration “warrant "
                           @"of removal/deportation” does not give the officer the authority to "
                           @"enter your home.)  If you tell the officers that the warrant is not complete "
                           @"or not accurate, you should say you do not consent to the search, "
                           @"but you should not interfere if the officers decide to do the search even "
                           @"after you have told them they are mistaken. Call your lawyer as soon as "
                           @"possible. Ask if you are allowed to watch the search; if you are allowed "
                           @"to, you should. Take notes, including names, badge numbers, which "
                           @"agency each officer is from, where they searched and what they took. If "
                           @"others are present, have them act as witnesses to watch carefully what "
                           @"is happening.", nil),
         NSLocalizedString(@"No. Neither a search nor arrest warrant means you have to answer "
                           @"questions.", nil),
         NSLocalizedString(@"You do not have to let law enforcement officers search your home, "
                           @"and you do not have to answer their questions. Law enforcement officers "
                           @"cannot get a warrant based on your refusal, nor can they punish you for "
                           @"refusing to give consent.", nil),
         NSLocalizedString(@"You can still tell them that you do not consent to the search and that "
                           @"they need to get a warrant. The officers may or may not succeed in getting "
                           @"a warrant if they follow through and ask the court for one, but once "
                           @"you give your consent, they do not need to try to get the court’s permission "
                           @"to do the search.", nil),
         NSLocalizedString(@"You should not interfere with the search in any way because "
                           @"you could get arrested. But you should say clearly that you "
                           @"have not given your consent and that the search is against your "
                           @"wishes. If someone is there with you, ask him or her to witness "
                           @"that you are not giving permission for the search. Call your "
                           @"lawyer as soon as possible. Take note of the names and badge "
                           @"numbers of the searching officers", nil), nil];
        
        
        NSArray* nonCitizensQuestions =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What types of law enforcement officers may try to question me?", nil),
         NSLocalizedString(@"What can I do if law enforcement officers want to question me?", nil),
         NSLocalizedString(@"Do I have to answer questions about whether I am a U.S. citizen, "
                           @"where I was born, where I live, where I am from, or other "
                           @"questions about my immigration status?", nil),
         NSLocalizedString(@"Do I have to show officers my immigration documents?", nil),
         NSLocalizedString(@"What should I do if there is an immigration raid where I work?", nil),
         NSLocalizedString(@"What can I do if immigration officers are arresting me and I "
                           @"have children in my care or my children need to be picked up "
                           @"and taken care of?", nil),
         NSLocalizedString(@"What should I do if immigration officers arrest me?", nil),
         NSLocalizedString(@"Do I have the right to talk to a lawyer before answering any "
                           @"law enforcement officers’ questions or signing any immigration "
                           @"papers?", nil),
         NSLocalizedString(@"If I am arrested for immigration violations, do I have "
                           @"the right to a hearing before an immigration judge to "
                           @"defend myself against deportation charges?", nil),
         NSLocalizedString(@"Can I be detained while my immigration case is happening?", nil),
         NSLocalizedString(@"Can I call my consulate if I am arrested?", nil),
         NSLocalizedString(@"What happens if I give up my right to a hearing or "
                           @"leave the U.S. before the hearing is over?", nil),
         NSLocalizedString(@"What should I do if I want to contact immigration officials?", nil),
         NSLocalizedString(@"What if I am charged with a crime?", nil), nil];
        
        NSArray* nonCitizensAnswers =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Different kinds of law enforcement officers might question you or ask "
                           @"you to agree to an interview where they would ask questions about your "
                           @"background, immigration status, relatives, colleagues and other topics. "
                           @"You may encounter the full range of law enforcement officers listed in "
                           @"Section 1.", nil),
         NSLocalizedString(@"You have the same right to be silent that U.S. citizens have, so the "
                           @"general rule is that you do not have to answer any questions that a law "
                           @"enforcement officer asks you. However, there are exceptions to this at "
                           @"ports of entry, such as airports and borders (see Section 5).", nil),
         NSLocalizedString(@"You do not have to answer any of the above questions if you do not "
                           @"want to answer them. But do not falsely claim U.S. citizenship. It is "
                           @"almost always a good idea to speak with a lawyer before you answer "
                           @"questions about your immigration status. Immigration law is very "
                           @"complicated, and you could have a problem without realizing it. A lawyer can "
                           @"help protect your rights, advise you, and help you avoid a problem. "
                           @"Always remember that even if you have answered some questions, you "
                           @"can still decide you do not want to answer any more questions. "
                           @"For “nonimmigrants” (a “nonimmigrant” is a non-citizen who is "
                           @"authorized to be in the U.S. for a particular reason or activity, usually for "
                           @"a limited period of time, such as a person with a tourist, student, or "
                           @"work visa), there is one limited exception to the rule that non-citizens "
                           @"who are already in the U.S. do not have to answer law enforcement "
                           @"officers’ questions: immigration officers can require "
                           @"nonimmigrants to provide information related to their immigration "
                           @"status. However, even if you are a nonimmigrant, you can still "
                           @"say that you would like to have your lawyer with you before you "
                           @"answer questions, and you have the right to stay silent if your "
                           @"answer to a question could be used against you in a criminal case.", nil),
         NSLocalizedString(@"The law requires non-citizens who are 18 or older and who "
                           @"have been issued valid U.S. immigration documents to carry "
                           @"those documents with them at all times. (These immigration "
                           @"documents are often called “alien registration” documents. "
                           @"The type you need to carry depends on your immigration status. "
                           @"Some examples include an unexpired permanent resident "
                           @"card (“green card”), I-94, Employment Authorization Document "
                           @"(EAD), or border crossing card.)  Failure to comply carry these "
                           @"documents can be a misdemeanor crime. "
                           @"If you have your valid U.S. immigration documents and "
                           @"you are asked for them, then it is usually a good idea to show "
                           @"them to the officer because it is possible that you will be "
                           @"arrested if you do not do so. Keep a copy of your documents in "
                           @"a safe place and apply for a replacement immediately if you "
                           @"lose your documents or if they are going to expire. If you are "
                           @"arrested because you do not have your U.S. immigration documents "
                           @"with you, but you have them elsewhere, ask a friend or "
                           @"family member (preferably one who has valid immigration status) "
                           @"to bring them to you. "
                           @"It is never a good idea to show an officer fake immigration "
                           @"documents or to pretend that someone else’s immigration "
                           @"documents are yours. If you are undocumented and therefore "
                           @"do not have valid U.S. immigration documents, you can decide "
                           @"not to answer questions about your citizenship or immigration "
                           @"status or whether you have documents. If you tell an immigration "
                           @"officer that you are not a U.S. citizen and you then cannot "
                           @"produce valid U.S. immigration documents, there is a very good "
                           @"chance you will be arrested.", nil),
         NSLocalizedString(@"If your workplace is raided, it may not be clear to you "
                           @"whether you are free to leave. Either way, you have the right to "
                           @"remain silent-you do not have to answer questions about your "
                           @"citizenship, immigration status or anything else. If you do "
                           @"answer questions and you say that you are not a U.S. citizen, you will be "
                           @"expected to produce immigration documents showing your immigration "
                           @"status. If you try to run away, the immigration officers will assume that "
                           @"you are in the U.S. illegally and you will likely be arrested. The safer "
                           @"course is to continue with your work or calmly ask if you may leave, and "
                           @"to not answer any questions you do not want to answer. (If you are a "
                           @"“nonimmigrant,” see above.)", nil),
         NSLocalizedString(@"If you have children with you when you are arrested, ask the officers "
                           @"if you can call a family member or friend to come take care of them "
                           @"before the officers take you away. If you are arrested when your children "
                           @"are at school or elsewhere, call a friend or family member as soon as "
                           @"possible so that a responsible adult will be able to take care of them.", nil),
         NSLocalizedString(@"Assert your rights.Non-citizens have rights that are important for "
                           @"their immigration cases. You do not have to answer questions. You can "
                           @"tell the officer you want to speak with a lawyer. You do not have to sign "
                           @"anything giving up your rights, and should never sign anything without "
                           @"reading, understanding and knowing the consequences of signing it. If "
                           @"you do sign a waiver, immigration agents could try to deport you before "
                           @"you see a lawyer or a judge. The immigration laws are hard to understand. "
                           @"There may be options for you that the immigration officers will "
                           @"not explain to you. You should talk to a lawyer before signing anything or "
                           @"making a decision about your situation. If possible, carry with you the "
                           @"name and telephone number of a lawyer who will take your calls.", nil),
         NSLocalizedString(@"Yes. You have the right to call a lawyer or your family if you are "
                           @"detained, and you have the right to be visited by a lawyer in detention. "
                           @"You have the right to have your attorney with you at any hearing before "
                           @"an immigration judge. You do not have the right to a government-"
                           @"appointed attorney for immigration proceedings, but immigration "
                           @"officials must give you a list of free or low-cost legal service providers. "
                           @"You have the right to hire your own immigration attorney.", nil),
         NSLocalizedString(@"Yes. In most cases only an immigration judge can order you "
                           @"deported. But if you waive your rights, sign something called a "
                           @"“Stipulated Removal Order,” or take “voluntary departure,” "
                           @"agreeing to leave the country, you could be deported without a "
                           @"hearing. There are some reasons why a person might not have "
                           @"a right to see an immigration judge, but even if you are told "
                           @"that this is your situation, you should speak with a lawyer "
                           @"immediately-immigration officers do not always know or tell "
                           @"you about exceptions that may apply to you; and you could have "
                           @"a right that you do not know about. Also, it is very important "
                           @"that you tell the officer (and contact a lawyer) immediately if "
                           @"you fear persecution or torture in your home country-you have "
                           @"additional rights if you have this fear, and you may be able to "
                           @"win the right to stay here.", nil),
         NSLocalizedString(@"In many cases, you will be detained, but most people are "
                           @"eligible to be released on bond or other reporting conditions. If "
                           @"you are denied release after you are arrested for an immigration "
                           @"violation, ask for a bond hearing before an immigration "
                           @"judge. In many cases, an immigration judge can order that you "
                           @"be releasedor that your bond be lowered.", nil),
         NSLocalizedString(@"Yes. Non-citizens arrested in the U.S. have the right to call "
                           @"their consulate or to have the law enforcement officer tell the "
                           @"consulate of your arrest. Law enforcement must let your consulate "
                           @"visit or speak with you if consular officials decide to do so. "
                           @"Your consulate might help you find a lawyer or offer other help.", nil),
         NSLocalizedString(@"If you are deported, you could lose your eligibility for certain "
                           @"immigration benefits, and you could be barred from returning "
                           @"to the U.S. for a number of years or, in some cases, permanently. "
                           @"The same is true if you do not go to your hearing and "
                           @"the immigration judge rules against you in your absence. If the "
                           @"government allows you to do “voluntary departure,” you may "
                           @"avoid some of the problems that come with having a deportation "
                           @"order and you may have a better chance at having a future opportunity "
                           @"to return to the U.S., but you should discuss your case with a lawyer "
                           @"because even with voluntary departure, there can be bars to returning, "
                           @"and you may be eligible for relief in immigration court. You should "
                           @"always talk to an immigration lawyer before you decide to give up your "
                           @"right to a hearing.", nil),
         NSLocalizedString(@"Always try to talk to a lawyer before contacting immigration officials, "
                           @"even on the phone. Many immigration officials view “enforcement” as "
                           @"their primary job and will not explain all of your options to you, and you "
                           @"could have a problem with your immigration status without knowing it.", nil),
         NSLocalizedString(@"Criminal convictions can make you deportable. You should always "
                           @"speak with your lawyer about the effect that a conviction or plea could "
                           @"have on your immigration status. Do not agree to a plea bargain without "
                           @"understanding if it could make you deportable or ineligible for relief or "
                           @"for citizenship.", nil), nil];
        
        NSArray* portsOfEntryQuestions =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What types of officers could I encounter at the airport and at the border?", nil),
         NSLocalizedString(@"If I am entering the U.S. with valid travel papers, can "
                           @"law enforcement officers stop and search me?", nil),
         NSLocalizedString(@"Can law enforcement officers ask questions about my "
                           @"immigration status?", nil),
         NSLocalizedString(@"If I am selected for a longer interview when I am "
                           @"coming into the United States, what can I do?", nil),
         NSLocalizedString(@"Can law enforcement officers search my laptop files?  If they "
                           @"do, can they make copies of the files, or information from my "
                           @"address book, papers, or cell phone contacts?", nil),
         NSLocalizedString(@"Can my bags or I be searched after going through metal "
                           @"detectors with no problem or after security sees that my bags do "
                           @"not contain a weapon?", nil),
         NSLocalizedString(@"What if I wear a religious head covering and I am selected by "
                           @"airport security officials for additional screening?", nil),
         NSLocalizedString(@"What if I am selected for a strip search?", nil),
         NSLocalizedString(@"If I am on an airplane, can an airline employee interrogate me or ask me to get off the plane?", nil),
         NSLocalizedString(@"What do I do if I am questioned by law enforcement "
                           @"officers every time I travel by air and I believe I am on a "
                           @"“no-fly” or other “national security” list?", nil),
         NSLocalizedString(@"If I believe that customs or airport agents or airline "
                           @"employees singled me out because of my race, ethnicity, "
                           @"or religion or that I was mistreated in other ways, what "
                           @"information should I record during and after the incident?", nil), nil];
        
        NSArray* portsOfEntryAnswers =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"You may encounter any of the full range of law enforcement "
                           @"officers listed above in Section 1. In particular, at airports and "
                           @"at the border you are likely to encounter customs agents, "
                           @"immigration officers, and Transportation and Safety "
                           @"Administration (TSA) officers.", nil),
         NSLocalizedString(@"Yes. Customs officers have the right to stop, detain and "
                           @"search any person or item. But officers cannot select you for a "
                           @"personal search based on your race, gender, religious or ethnic "
                           @"background. If you are a non-citizen, you should carry your "
                           @"green card or other valid immigration status documents at all "
                           @"times.", nil),
         NSLocalizedString(@"Yes. At airports, law enforcement officers have the power to "
                           @"determine whether or not you have the right or permission to "
                           @"enter or return to the U.S.", nil),
         NSLocalizedString(@"If you are a U.S. citizen, you have the right to have an attorney "
                           @"present for any questioning. If you are a non-citizen, you "
                           @"generally do not have the right to an attorney when you have "
                           @"arrived at an airport or another port of entry and an immigration "
                           @"officer is inspecting you to decide whether or not you will "
                           @"be admitted. However, you do have the right to an attorney if "
                           @"the questions relate to anything other than your immigration "
                           @"status. You can ask an officer if he or she will allow you to "
                           @"answer extended questioning at a later time, but the request may or may "
                           @"not be granted. If you are not a U.S. citizen and an officer says you "
                           @"cannot come into the U.S., but you fear that you will be persecuted or "
                           @"tortured if sent back to the country you came from, tell the officer about "
                           @"your fear and say that you want asylum.", nil),
         NSLocalizedString(@"This issue is contested right now. Generally, law enforcement officers "
                           @"can search your laptop files and make copies of information contained in "
                           @"the files. If such a search occurs, you should write down the name, "
                           @"badge number, and agency of the person who conducted the search. You "
                           @"should also file a complaint with that agency.", nil),
         NSLocalizedString(@"Yes. Even if the initial screen of your bags reveals nothing suspicious, "
                           @"the screeners have the authority to conduct a further search of you or "
                           @"your bags.", nil),
         NSLocalizedString(@"You have the right to wear religious head coverings. You should assert "
                           @"your right to wear your religious head covering if asked to remove it. The "
                           @"current policy (which is subject to change) relating to airport screeners "
                           @"and requiring removal of religious head coverings, such as a turban or "
                           @"hijab, is that if an alarm goes off when you walk through the metal "
                           @"detector the TSA officer may then use a hand-wand to determine if the "
                           @"alarm is coming from your religious head covering. If the alarm is coming "
                           @"from your religious head covering the TSA officer may want to "
                           @"pat-down or have you remove your religious head covering. You have the "
                           @"right to request that this pat-down or removal occur in a private area. If "
                           @"no alarm goes off when you go through the metal detector the TSA officer "
                           @"may nonetheless determine that additional screening is required for "
                           @"non-metallic items. Additional screening cannot be required on a "
                           @"discriminatory basis (because of race, gender, religion, national origin or "
                           @"ancestry). The TSA officer will ask you if he or she can pat-down your "
                           @"religious head covering. If you do not want the TSA officer to touch your "
                           @"religious head covering you must refuse and say that you would prefer to "
                           @"pat-down your own religious head covering. You will then be taken aside "
                           @"and a TSA officer will supervise you as you pat-down your religious head "
                           @"covering. After the pat-down the TSA officer will rub your "
                           @"hands with a small cotton cloth and place it in a machine to "
                           @"test for chemical residue. If you pass this chemical residue "
                           @"test, you should be allowed to proceed to your flight. If the TSA "
                           @"officer insists on the removal of your religious head covering "
                           @"you have a right to ask that it be done in a private area.", nil),
         NSLocalizedString(@"A strip search at the border is not a routine search and "
                           @"must be supported by “reasonable suspicion,” and must be "
                           @"done in a private area.", nil),
         NSLocalizedString(@"The pilot of an airplane has the right to refuse to fly a "
                           @"passenger if he or she believes the passenger is a threat to the "
                           @"safety of the flight. The pilot’s decision must be reasonable and "
                           @"based on observations of you, not stereotypes.", nil),
         NSLocalizedString(@"If you believe you are mistakenly on a list you should contact "
                           @"the Transportation Security Administration and file an inquiry "
                           @"using the Traveler Redress Inquiry Process. The form is available at "
                           @"http://www.tsa.gov/travelers/customer/redress/index.shtm. "
                           @"You should also fill out a complaint form with the ACLU at "
                           @"http://www.aclu.org/noflycomplaint. If you think there may be "
                           @"some legitimate reason for why you have been placed on a list, "
                           @"you should seek the advice of an attorney.", nil),
         NSLocalizedString(@"It is important to record the details of the incident while they "
                           @"are fresh in your mind. When documenting the sequence of "
                           @"events, be sure to note the airport, airline, flight number, the "
                           @"names and badge numbers of any law enforcement officers "
                           @"involved, information on any airline or airport personnel "
                           @"involved, questions asked in any interrogation, stated reason "
                           @"for treatment, types of searches conducted, and length and conditions of "
                           @"detention. When possible, it is helpful to have a witness to the incident. If "
                           @"you have been mistreated or singled out at the airport based on your "
                           @"race, ethnicity or religion, please fill out the Passenger Profiling "
                           @"Complaint Form on the ACLU’s web site at http://www.aclu.org/airlineprofiling, "
                           @"and file a complaint with the U.S. Department of "
                           @"Transportation at "
                           @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm.", nil), nil];
        
        NSArray* portsOfEntryLinks =
        [NSArray arrayWithObjects:
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray arrayWithObjects:@"http://www.tsa.gov/travelers/customer/redress/index.shtm", @"http://www.aclu.org/noflycomplaint", nil],
         [NSArray arrayWithObjects:@"http://www.aclu.org/airlineprofiling", @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm", nil],
         nil];
        
        NSArray* charitableDonationsQuestions =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Can I give to a charity organization without becoming a "
                           @"terror suspect?", nil),
         NSLocalizedString(@"Is it safe for me to practice my religion in religious "
                           @"institutions or public places?", nil),
         NSLocalizedString(@"What else can I do to be prepared?", nil), nil];
        
        NSArray* charitableDonationsAnswers =
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Yes. You should continue to give money to the causes you believe "
                           @"in, but you should be careful in choosing which charities to support."
                           @"For helpful tips, see Muslim Advocates’ guide on charitable giving: "
                           @"http://www.muslimadvocates.org/documents/safe_donating.html.", nil),
         NSLocalizedString(@"Yes. Worshipping as you want is your constitutional right. You "
                           @"have the right to go to a place of worship, attend and hear sermons "
                           @"and religious lectures, participate in community activities, and pray "
                           @"in public. While there have been news stories recently about people "
                           @"being unfairly singled out for doing these things, the law is on your "
                           @"side to protect you.", nil),
         NSLocalizedString(@"You should keep informed about issues that matter to you by "
                           @"going to the library, reading the news, surfing the internet, and "
                           @"speaking out about what is important to you. In case of emergency, "
                           @"you should have a family plan-the number of a good friend or "
                           @"relative that anyone in the family can call if they need help, as well "
                           @"as the number of an attorney. If you are a non-citizen, remember to "
                           @"carry your immigration documents with you.", nil), nil];
        
        NSArray* charitableDonationsLinks =
        [NSArray arrayWithObjects:
         [NSArray arrayWithObjects:@"http://www.muslimadvocates.org/documents/safe_donating.html", nil],
         [NSArray array],
         [NSArray array], nil];
        
        questions = [[NSArray arrayWithObjects:
                      questioningQuestions,
                      stopsAndArrestsQuestions,
                      searchesAndWarrantsQuestions,
                      nonCitizensQuestions,
                      portsOfEntryQuestions,
                      charitableDonationsQuestions, nil] retain];
        answers = [[NSArray arrayWithObjects:
                    questioningAnswers,
                    stopsAndArrestsAnswers,
                    searchesAndWarrantsAnswers,
                    nonCitizensAnswers,
                    portsOfEntryAnswers,
                    charitableDonationsAnswers, nil] retain];
        
        links = [[NSArray arrayWithObjects:
                  [NSArray array],
                  [NSArray array],
                  [NSArray array],
                  [NSArray array],
                  portsOfEntryLinks,
                  charitableDonationsLinks, nil] retain];
    }
}


@synthesize rssCache;

- (void) dealloc {
    self.rssCache = nil;
    [super dealloc];
}


- (void) updateCaches:(NSNumber*) number {
    NSInteger value = [number integerValue];
    
    switch (value) {
        case 0:
            [rssCache update];
            break;
            
        default:
            return;
    }
    
    [self performSelector:@selector(updateCaches:)
               withObject:[NSNumber numberWithInt:value + 1]
               afterDelay:1];
}


- (id) init {
    if (self = [super init]) {
        self.rssCache = [RSSCache cacheWithModel:self];
        [self updateCaches:[NSNumber numberWithInt:0]];
    }
    
    return self;
}


- (NSArray*) sectionTitles {
    return sectionTitles;
}


- (NSArray*) shortSectionTitles {
    return shortSectionTitles;
}


- (NSString*) shortSectionTitleForSectionTitle:(NSString*) sectionTitle {
    return [shortSectionTitles objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


- (NSString*) preambleForSectionTitle:(NSString*) sectionTitle {
    return [preambles objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


- (NSArray*) questionsForSectionTitle:(NSString*) sectionTitle {
    return [questions objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


- (NSArray*) otherResourcesForSectionTitle:(NSString*) sectionTitle {
    return [otherResources objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


- (NSArray*) answersForSectionTitle:(NSString*) sectionTitle {
    return [answers objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


- (NSString*) answerForQuestion:(NSString*) question withSectionTitle:(NSString*) sectionTitle {
    NSArray* questions = [self questionsForSectionTitle:sectionTitle];
    NSArray* specificAnswers = [self answersForSectionTitle:sectionTitle];
    
    return [specificAnswers objectAtIndex:[questions indexOfObject:question]];
}


NSInteger compareLinks(id link1, id link2, void* context) {
    NSRange range1 = [link1 rangeOfString:@"@"];
    NSRange range2 = [link2 rangeOfString:@"@"];
    
    if (range1.length > 0 && range2.length == 0) {
        return NSOrderedDescending;
    } else if (range2.length > 0 && range1.length == 0) {
        return NSOrderedAscending;
    } else {
        return [link1 compare:link2];
    }
}


- (NSArray*) linksForSectionTitle:(NSString*) sectionTitle {
    NSArray* result = [sectionLinks objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
    return [result sortedArrayUsingFunction:compareLinks context:NULL];
}


- (NSArray*) linksForQuestion:(NSString*) question withSectionTitle:(NSString*) sectionTitle {
    NSArray* questions = [self questionsForSectionTitle:sectionTitle];
    NSArray* specificLinks = [links objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
    if (specificLinks.count == 0) {
        return [NSArray array];
    }
    
    NSArray* result = [specificLinks objectAtIndex:[questions indexOfObject:question]];
    return [result sortedArrayUsingFunction:compareLinks context:NULL];
}


- (NSArray*) toughQuestions {
    return toughQuestions;
}


- (NSString*) answerForToughQuestion:(NSString*) question {
    return [toughAnswers objectAtIndex:[toughQuestions indexOfObject:question]];
}


- (NSInteger) greatestHitsSortIndex {
    return 0;
}


- (void) setGreatestHitsSortIndex:(NSInteger) index {
    
}


- (NSString*) feedbackUrl {
    NSString* body = [NSString stringWithFormat:@"\n\nVersion: %@\nCountry: %@\nLanguage: %@",
                      currentVersion,
                      [LocaleUtilities englishCountry],
                      [LocaleUtilities englishLanguage]];
    
    NSString* subject = @"Your%20Rights%20Feedback";
    
    NSString* encodedBody = [Utilities stringByAddingPercentEscapes:body];
    NSString* result = [NSString stringWithFormat:@"mailto:cyrus.najmabadi@gmail.com?subject=%@&body=%@", subject, encodedBody];
    return result;
}


- (Constitution*) unitedStatesConstitution {
    return unitedStatesConstitution;
}


- (Constitution*) articlesOfConfederation {
    return articlesOfConfederation;
}


- (Constitution*) federalistPapers {
    return federalistPapers;
}


- (DeclarationOfIndependence*) declarationOfIndependence {
    return declarationOfIndependence;
}

@end